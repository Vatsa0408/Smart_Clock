import 'package:flutter_test/flutter_test.dart';
import 'package:smart_clock/features/clock/clock_store.dart';

void main() {
  test('untilNextSecond lands just after the next whole second', () {
    expect(untilNextSecond(DateTime(2026, 1, 1, 0, 0, 0, 0)), const Duration(milliseconds: 1005));
    expect(untilNextSecond(DateTime(2026, 1, 1, 0, 0, 0, 999)), const Duration(milliseconds: 6));
  });
}
