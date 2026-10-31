part of 'clock_bloc.dart';

sealed class ClockEvent {
  const ClockEvent();
}

final class ClockTicked extends ClockEvent {
  const ClockTicked(this.now);
  final DateTime now;
}

final class ClockFormatToggled extends ClockEvent {
  const ClockFormatToggled();
}
