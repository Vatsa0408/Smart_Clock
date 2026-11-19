part of 'calendar_bloc.dart';

sealed class CalendarEvent {
  const CalendarEvent();
}

final class CalendarRequested extends CalendarEvent {
  const CalendarRequested();
}
