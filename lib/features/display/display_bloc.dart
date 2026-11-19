import 'dart:ui' show Offset;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'display_store.dart';

part 'display_event.dart';
part 'display_state.dart';

/// True when [m] (minutes after midnight) is inside [start, end); handles windows crossing midnight.
bool inWindow(int m, int start, int end) =>
    start <= end ? m >= start && m < end : m >= start || m < end;

/// Burn-in orbit position: one of 8 steps, advancing every 5 minutes.
int orbitIndex(DateTime t) => (t.hour * 60 + t.minute) ~/ 5 % 8;

/// Burn-in orbit positions: 4 px steps around the origin.
const orbitOffsets = [
  Offset.zero,
  Offset(4, 0),
  Offset(4, 4),
  Offset(0, 4),
  Offset(-4, 4),
  Offset(-4, 0),
  Offset(-4, -4),
  Offset(0, -4),
];

/// Plain Bloc: the schedule is persisted by SettingsBloc and pushed in by main.dart.
class DisplayBloc extends Bloc<DisplayEvent, DisplayState> {
  DisplayBloc(this._store) : super(const DisplayState()) {
    on<DisplayMinuteTicked>((e, emit) {
      _minute = e.now.hour * 60 + e.now.minute;
      final inWin = inWindow(_minute!, state.startMin, state.endMin);
      return _apply(emit, state.copyWith(
        inWin: inWin,
        suppressed: state.suppressed && inWin, // exit holds until the window ends
        shift: state.orbit ? orbitIndex(e.now) : 0,
      ));
    });
    on<DisplayScheduleSet>((e, emit) {
      final s = state.copyWith(startMin: e.startMin, endMin: e.endMin, nightBrightness: e.nightBrightness);
      // Re-evaluate right away, so editing the schedule at 23:10 dims without waiting a minute.
      return _apply(emit, _minute == null ? s : s.copyWith(inWin: inWindow(_minute!, s.startMin, s.endMin)));
    });
    on<DisplayOrbitSet>((e, emit) => emit(state.copyWith(orbit: e.on, shift: e.on ? state.shift : 0)));
    on<DisplayAutoSet>((e, emit) => _apply(emit, state.copyWith(auto: e.on)));
    on<DisplayNightManualSet>(
      (e, emit) => _apply(emit, state.copyWith(manual: e.on, suppressed: e.on ? false : state.suppressed)),
    );
    on<DisplayNightExited>((e, emit) => _apply(emit, state.copyWith(manual: false, suppressed: true)));
    on<DisplayOverheatChanged>((e, emit) => _apply(emit, state.copyWith(overheat: e.on)));
  }

  final DisplayStore _store;
  int? _minute; // last ticked minute-of-day

  /// Talks to the platform only when the effective brightness changes.
  Future<void> _apply(Emitter<DisplayState> emit, DisplayState next) async {
    final want = next.dim ? next.nightBrightness : null;
    final had = state.dim ? state.nightBrightness : null;
    if (want != had) await _store.setBrightness(want);
    emit(next);
  }
}
