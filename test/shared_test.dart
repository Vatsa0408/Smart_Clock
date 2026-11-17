import 'package:flutter_test/flutter_test.dart';
import 'package:smart_clock/features/clock/clock_store.dart';
import 'package:smart_clock/shared/ui.dart';

void main() {
  test('untilNextSecond lands just after the next whole second', () {
    expect(untilNextSecond(DateTime(2026, 1, 1, 0, 0, 0, 0)), const Duration(milliseconds: 1005));
    expect(untilNextSecond(DateTime(2026, 1, 1, 0, 0, 0, 999)), const Duration(milliseconds: 6));
  });

  test('ageLabel', () {
    expect(ageLabel(Duration.zero), 'just now');
    expect(ageLabel(const Duration(seconds: 59)), 'just now');
    expect(ageLabel(const Duration(minutes: 1)), '1 min ago');
    expect(ageLabel(const Duration(minutes: 59)), '59 min ago');
    expect(ageLabel(const Duration(minutes: 60)), '1 h ago');
    expect(ageLabel(const Duration(hours: 47)), '47 h ago');
    expect(ageLabel(const Duration(hours: 48)), '2 d ago');
  });
}
