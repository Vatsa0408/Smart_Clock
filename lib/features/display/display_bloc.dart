import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'display_store.dart';

part 'display_event.dart';
part 'display_state.dart';

/// True when [m] (minutes after midnight) is inside [start, end); handles windows crossing midnight.
bool inWindow(int m, int start, int end) =>
    start <= end ? m >= start && m < end : m >= start || m < end;

/// Plain Bloc: the schedule is persisted by SettingsBloc and pushed in by main.dart.
class DisplayBloc extends Bloc<DisplayEvent, DisplayState> {
  DisplayBloc(this._store) : super(const DisplayState()) {
    on<DisplayMinuteTicked>((e, emit) {
      _minute = e.now.hour * 60 + e.now.minute;
      return _apply(emit, state.copyWith(night: inWindow(_minute!, state.startMin, state.endMin)));
    });
    on<DisplayScheduleSet>((e, emit) {
      final s = state.copyWith(startMin: e.startMin, endMin: e.endMin, nightBrightness: e.nightBrightness);
      // Re-evaluate right away, so editing the schedule at 23:10 dims without waiting a minute.
      return _apply(emit, _minute == null ? s : s.copyWith(night: inWindow(_minute!, s.startMin, s.endMin)));
    });
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
