/// Source of ticks and wall-clock time.
class ClockStore {
  const ClockStore();
  DateTime now() => DateTime.now();
  Stream<DateTime> ticks() =>
      Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
}
