part of 'calendar_bloc.dart';

final class CalendarState extends Equatable {
  const CalendarState({this.events = const []});
  final List<CalendarItem> events;

  /// Next event: the rest of today, else the first one tomorrow.
  CalendarItem? next(DateTime now) {
    final m = now.hour * 60 + now.minute;
    return events.where((e) => e.day == 0 && e.h * 60 + e.m >= m).firstOrNull ??
        events.where((e) => e.day == 1).firstOrNull;
  }

  @override
  List<Object> get props => [events];
}
