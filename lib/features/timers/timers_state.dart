part of 'timers_bloc.dart';

final class TimerItem extends Equatable {
  const TimerItem({required this.id, required this.label, required this.total, required this.left, required this.running});
  final int id, total, left;
  final String label;
  final bool running;

  bool get done => left == 0;

  TimerItem copyWith({int? left, bool? running}) =>
      TimerItem(id: id, label: label, total: total, left: left ?? this.left, running: running ?? this.running);

  @override
  List<Object> get props => [id, label, total, left, running];
}

final class TimersState extends Equatable {
  const TimersState({
    this.timers = const [],
    this.seq = 1,
    this.stopwatchTab = false,
    this.swRunning = false,
    this.swSec = 0,
  });

  static const maxTimers = 3;

  final List<TimerItem> timers;
  final int seq;
  final bool stopwatchTab, swRunning;
  final int swSec;

  /// Timer shown as a chip on the clock card: first running, else first finished.
  TimerItem? get chip =>
      timers.where((t) => t.running).firstOrNull ?? timers.where((t) => t.done).firstOrNull;

  TimersState copyWith({List<TimerItem>? timers, int? seq, bool? stopwatchTab, bool? swRunning, int? swSec}) =>
      TimersState(
        timers: timers ?? this.timers,
        seq: seq ?? this.seq,
        stopwatchTab: stopwatchTab ?? this.stopwatchTab,
        swRunning: swRunning ?? this.swRunning,
        swSec: swSec ?? this.swSec,
      );

  @override
  List<Object> get props => [timers, seq, stopwatchTab, swRunning, swSec];
}
