import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_clock/features/display/display_bloc.dart';
import 'package:smart_clock/features/display/display_store.dart';

class _MockStore extends Mock implements DisplayStore {}

void main() {
  test('inWindow handles a window crossing midnight (22:00-07:00)', () {
    const start = 22 * 60, end = 7 * 60;
    expect(inWindow(23 * 60, start, end), isTrue);
    expect(inWindow(3 * 60, start, end), isTrue);
    expect(inWindow(12 * 60, start, end), isFalse);
    expect(inWindow(7 * 60, start, end), isFalse); // end is exclusive
  });

  test('orbitIndex steps every 5 minutes through 8 positions', () {
    expect(orbitIndex(DateTime(2026, 1, 1, 0, 0)), 0);
    expect(orbitIndex(DateTime(2026, 1, 1, 0, 5)), 1);
    expect(orbitIndex(DateTime(2026, 1, 1, 0, 39)), 7);
    expect(orbitIndex(DateTime(2026, 1, 1, 0, 40)), 0);
  });

  late _MockStore store;
  late DisplayBloc bloc;
  setUp(() {
    store = _MockStore();
    when(() => store.setBrightness(any())).thenAnswer((_) async {});
    bloc = DisplayBloc(store);
  });
  tearDown(() => bloc.close());

  Future<void> add(DisplayEvent e) async {
    bloc.add(e);
    await pumpEventQueue();
  }

  test('night tick dims; editing the schedule re-evaluates at once', () async {
    await add(DisplayMinuteTicked(DateTime(2026, 1, 1, 23)));
    expect(bloc.state.night, isTrue);
    verify(() => store.setBrightness(0.1)).called(1);

    await add(const DisplayScheduleSet(23 * 60 + 30, 7 * 60, 0.2));
    expect(bloc.state.night, isFalse);
    verify(() => store.setBrightness(null)).called(1);
  });

  test('schedule set before any tick leaves night unchanged', () async {
    await add(const DisplayScheduleSet(0, 23 * 60 + 59, 0.1));
    expect(bloc.state.night, isFalse);
    verifyNever(() => store.setBrightness(any()));
  });

  test('orbit on shifts with ticks; off resets to 0 and stays', () async {
    await add(const DisplayOrbitSet(true));
    await add(DisplayMinuteTicked(DateTime(2026, 1, 1, 0, 10)));
    expect(bloc.state.shift, 2);
    await add(const DisplayOrbitSet(false));
    expect(bloc.state.shift, 0);
    await add(DisplayMinuteTicked(DateTime(2026, 1, 1, 0, 15)));
    expect(bloc.state.shift, 0);
  });

  test('overheat dims at noon; no second brightness call when already night', () async {
    await add(DisplayMinuteTicked(DateTime(2026, 1, 1, 12)));
    await add(const DisplayOverheatChanged(true));
    expect(bloc.state.dim, isTrue);
    verify(() => store.setBrightness(0.1)).called(1);

    await add(const DisplayOverheatChanged(false));
    await add(DisplayMinuteTicked(DateTime(2026, 1, 1, 23)));
    clearInteractions(store);
    await add(const DisplayOverheatChanged(true));
    verifyNever(() => store.setBrightness(any()));
  });
}
