import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'clock_store.dart';

part 'clock_event.dart';
part 'clock_state.dart';

class ClockBloc extends HydratedBloc<ClockEvent, ClockState> {
  ClockBloc({ClockStore store = const ClockStore()})
      : super(ClockState(now: store.now())) {
    on<ClockTicked>((e, emit) => emit(state.copyWith(now: e.now)));
    on<ClockFormatToggled>(
        (e, emit) => emit(state.copyWith(hour24: !state.hour24)));
    _sub = store.ticks().listen((t) => add(ClockTicked(t)));
  }

  late final StreamSubscription<DateTime> _sub;

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }

  @override
  ClockState? fromJson(Map<String, dynamic> json) =>
      ClockState(now: DateTime.now(), hour24: json['hour24'] as bool? ?? true);

  @override
  Map<String, dynamic>? toJson(ClockState state) => {'hour24': state.hour24};
}
