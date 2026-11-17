import 'package:flutter_test/flutter_test.dart';
import 'package:smart_clock/features/display/display_bloc.dart';

void main() {
  test('inWindow handles a window crossing midnight (22:00-07:00)', () {
    const start = 22 * 60, end = 7 * 60;
    expect(inWindow(23 * 60, start, end), isTrue);
    expect(inWindow(3 * 60, start, end), isTrue);
    expect(inWindow(12 * 60, start, end), isFalse);
    expect(inWindow(7 * 60, start, end), isFalse); // end is exclusive
  });
}
