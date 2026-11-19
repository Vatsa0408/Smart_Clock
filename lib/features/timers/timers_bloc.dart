import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'timers_event.dart';
part 'timers_state.dart';

/// Countdown timers and the stopwatch; ticked once a second from main.dart (clock ticks).
class TimersBloc extends Bloc<TimersEvent, TimersState> {
  TimersBloc() : super(const TimersState()) {
    on<TimerAdded>((e, emit) {
      if (state.timers.length >= TimersState.maxTimers) return;
      emit(state.copyWith(
        timers: [
          ...state.timers,
          TimerItem(id: state.seq, label: '${e.minutes} min timer', total: e.minutes * 60, left: e.minutes * 60, running: true),
        ],
        seq: state.seq + 1,
      ));
    });
    on<TimerToggled>((e, emit) => emit(state.copyWith(
          timers: [for (final t in state.timers) t.id == e.id ? t.copyWith(running: !t.running) : t],
        )));
    on<TimerRemoved>((e, emit) => emit(state.copyWith(timers: state.timers.where((t) => t.id != e.id).toList())));
    on<TimersTabChanged>((e, emit) => emit(state.copyWith(stopwatchTab: e.stopwatch)));
    on<StopwatchToggled>((e, emit) => emit(state.copyWith(swRunning: !state.swRunning)));
    on<StopwatchReset>((e, emit) => emit(state.copyWith(swRunning: false, swSec: 0)));
    on<TimersTicked>((e, emit) {
      if (!state.swRunning && !state.timers.any((t) => t.running)) return;
      emit(state.copyWith(
        swSec: state.swRunning ? state.swSec + 1 : null,
        timers: [
          for (final t in state.timers)
            t.running ? t.copyWith(left: t.left - 1, running: t.left - 1 > 0) : t,
        ],
      ));
    });
  }
}
