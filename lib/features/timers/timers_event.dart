part of 'timers_bloc.dart';

sealed class TimersEvent {
  const TimersEvent();
}

final class TimerAdded extends TimersEvent {
  const TimerAdded(this.minutes);
  final int minutes;
}

final class TimerToggled extends TimersEvent {
  const TimerToggled(this.id);
  final int id;
}

/// Stop a running timer or clear a finished one.
final class TimerRemoved extends TimersEvent {
  const TimerRemoved(this.id);
  final int id;
}

final class TimersTabChanged extends TimersEvent {
  const TimersTabChanged({required this.stopwatch});
  final bool stopwatch;
}

final class StopwatchToggled extends TimersEvent {
  const StopwatchToggled();
}

final class StopwatchReset extends TimersEvent {
  const StopwatchReset();
}

final class TimersTicked extends TimersEvent {
  const TimersTicked();
}
