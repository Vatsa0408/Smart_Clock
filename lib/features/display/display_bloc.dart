import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'display_store.dart';

part 'display_event.dart';
part 'display_state.dart';

/// True when [m] (minutes after midnight) is inside [start, end); handles windows crossing midnight.
bool inWindow(int m, int start, int end) =>
    start <= end ? m >= start && m < end : m >= start || m < end;

class DisplayBloc extends HydratedBloc<DisplayEvent, DisplayState> {
  DisplayBloc(this._store) : super(const DisplayState()) {
    on<DisplayMinuteTicked>((e, emit) async {
      final night = inWindow(e.now.hour * 60 + e.now.minute, state.startMin, state.endMin);
      if (night == state.night) return;
      await _store.setBrightness(night ? state.nightBrightness : null);
      emit(state.copyWith(night: night));
    });
  }

  final DisplayStore _store;

  // Only the schedule persists; `night` is recomputed on the next minute tick.
  @override
  DisplayState? fromJson(Map<String, dynamic> json) => DisplayState(
        startMin: json['start'] as int,
        endMin: json['end'] as int,
        nightBrightness: (json['bright'] as num).toDouble(),
      );

  @override
  Map<String, dynamic>? toJson(DisplayState state) =>
      {'start': state.startMin, 'end': state.endMin, 'bright': state.nightBrightness};
}
