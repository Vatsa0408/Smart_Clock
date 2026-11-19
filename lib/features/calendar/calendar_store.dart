/// An event today ([day] 0) or tomorrow ([day] 1).
final class CalendarItem {
  const CalendarItem(this.day, this.h, this.m, this.title);
  final int day, h, m;
  final String title;
}

/// Placeholder: sample events from the design. Swap in Google Calendar / device calendar here.
class CalendarStore {
  const CalendarStore();

  Future<List<CalendarItem>> events() async => const [
        CalendarItem(0, 9, 30, 'Team stand-up'),
        CalendarItem(0, 11, 0, 'Sprint review'),
        CalendarItem(0, 14, 30, 'Dentist'),
        CalendarItem(1, 10, 0, 'Planning'),
        CalendarItem(1, 13, 0, 'Lunch with Anna'),
      ];
}
