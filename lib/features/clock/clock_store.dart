import 'dart:async';

/// Delay to the next whole second, +5 ms so an early-firing timer
/// (Windows timer resolution) never lands in the old second.
Duration untilNextSecond(DateTime now) => Duration(milliseconds: 1005 - now.millisecond);

/// Source of ticks and wall-clock time.
class ClockStore {
  const ClockStore();
  DateTime now() => DateTime.now();

  /// Re-arms a one-shot timer every tick, so cancelling leaves nothing pending.
  Stream<DateTime> ticks() {
    late final StreamController<DateTime> c;
    Timer? t;
    void arm() => t = Timer(untilNextSecond(now()), () {
          c.add(now());
          arm();
        });
    c = StreamController<DateTime>(onListen: arm, onCancel: () => t?.cancel());
    return c.stream;
  }
}
