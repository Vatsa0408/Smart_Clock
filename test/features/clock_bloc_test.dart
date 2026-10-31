import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_clock/features/clock/clock_bloc.dart';

class _MockStorage extends Mock implements Storage {}

void main() {
  setUp(() {
    final storage = _MockStorage();
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  test('India offset is computed from UTC+5:30', () {
    // 12:00 UTC on a UTC device -> 17:30 IST, 5 h 30 min ahead.
    final s = ClockState(now: DateTime.utc(2026, 1, 1, 12));
    expect(s.india.hour, 17);
    expect(s.india.minute, 30);
    expect(s.indiaOffset, startsWith('5 h 30 min ahead'));
  });

  blocTest<ClockBloc, ClockState>(
    'toggles 24h/12h format',
    build: ClockBloc.new,
    act: (b) => b.add(const ClockFormatToggled()),
    expect: () => [isA<ClockState>().having((s) => s.hour24, 'hour24', false)],
  );
}
