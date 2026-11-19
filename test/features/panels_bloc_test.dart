import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_clock/features/alarms/alarms_bloc.dart';
import 'package:smart_clock/features/alarms/alarms_store.dart';
import 'package:smart_clock/features/display/display_bloc.dart';
import 'package:smart_clock/features/display/display_store.dart';
import 'package:smart_clock/features/timers/timers_bloc.dart';
import 'package:smart_clock/features/todo/todo_bloc.dart';

class _MockStorage extends Mock implements Storage {}

class _MockDisplay extends Mock implements DisplayStore {}

void main() {
  setUp(() {
    final storage = _MockStorage();
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  // Thursday 2026-01-01 is weekday 4 (Mon = 1).
  final thu = DateTime(2026, 1, 1, 6, 0);

  test('nextAlarm picks the soonest enabled alarm and skips disabled and passed ones', () {
    final n = nextAlarm(defaultAlarms, thu);
    expect(n?.alarm.label, 'Work'); // Thu 06:30
    expect(n?.d, 0);
    expect(nextAlarm(defaultAlarms, DateTime(2026, 1, 1, 7))?.alarm.label, 'Work'); // tomorrow (Fri)
    expect(nextAlarmText(defaultAlarms, DateTime(2026, 1, 1, 7), (h, m) => hm2(h, m)), 'Tomorrow 06:30');
    expect(nextAlarm([const Alarm(on: false)], thu), isNull);
  });

  test('alarm fires on its minute, snoozes, then rings again', () async {
    final bloc = AlarmsBloc();
    addTearDown(bloc.close);
    bloc.add(AlarmMinuteTicked(DateTime(2026, 1, 1, 6, 30)));
    await pumpEventQueue();
    expect(bloc.state.ringing?.label, 'Work');

    bloc.add(AlarmSnoozed(DateTime(2026, 1, 1, 6, 30, 20)));
    await pumpEventQueue();
    expect(bloc.state.ringing, isNull);
    expect(bloc.state.snoozeAt, DateTime(2026, 1, 1, 6, 40));

    bloc.add(AlarmMinuteTicked(DateTime(2026, 1, 1, 6, 39)));
    await pumpEventQueue();
    expect(bloc.state.ringing, isNull);
    bloc.add(AlarmMinuteTicked(DateTime(2026, 1, 1, 6, 40)));
    await pumpEventQueue();
    expect(bloc.state.ringing?.label, 'Work');

    bloc.add(const AlarmDismissed());
    await pumpEventQueue();
    expect(bloc.state.ringing, isNull);
    expect(bloc.state.snoozeAt, isNull);
  });

  test('one-shot alarm switches itself off; editor saves a new alarm', () async {
    final bloc = AlarmsBloc();
    addTearDown(bloc.close);
    bloc.add(const AlarmEditStarted());
    bloc.add(AlarmDraftChanged(const Alarm(h: 9, m: 5, label: '  ')));
    bloc.add(const AlarmSaved());
    await pumpEventQueue();
    expect(bloc.state.alarms, hasLength(4));
    expect(bloc.state.alarms.last.label, 'Alarm');
    expect(bloc.state.editing, isNull);

    bloc.add(AlarmMinuteTicked(DateTime(2026, 1, 1, 9, 5)));
    await pumpEventQueue();
    expect(bloc.state.ringing?.id, bloc.state.alarms.last.id);
    expect(bloc.state.alarms.last.on, isFalse);
  });

  test('alarm json round-trips', () {
    const a = Alarm(id: 5, h: 1, m: 2, label: 'x', days: [true, false, false, false, false, false, true], sound: 2, hold: true, ac: true);
    expect(Alarm.fromJson(a.toJson()), a);
  });

  test('timers count down, finish, and are limited to three; stopwatch runs', () async {
    final bloc = TimersBloc();
    addTearDown(bloc.close);
    for (var i = 0; i < 4; i++) {
      bloc.add(const TimerAdded(5));
    }
    bloc.add(const StopwatchToggled());
    bloc.add(const TimersTicked());
    await pumpEventQueue();
    expect(bloc.state.timers, hasLength(3));
    expect(bloc.state.timers.first.left, 299);
    expect(bloc.state.swSec, 1);

    final one = TimersBloc()..add(const TimerAdded(5));
    addTearDown(one.close);
    for (var i = 0; i < 300; i++) {
      one.add(const TimersTicked());
    }
    await pumpEventQueue();
    expect(one.state.timers.single.done, isTrue);
    expect(one.state.timers.single.running, isFalse);
    expect(one.state.chip?.done, isTrue);
  });

  test('todo is capped at five items and ignores blank text', () async {
    final bloc = TodoBloc();
    addTearDown(bloc.close);
    bloc.add(const TodoAdded('   '));
    bloc.add(const TodoAdded('a'));
    bloc.add(const TodoAdded('b'));
    bloc.add(const TodoAdded('c'));
    await pumpEventQueue();
    expect(bloc.state.items, hasLength(5));
    expect(bloc.state.full, isTrue);
    expect(bloc.state.open, 4);
  });

  test('night: manual on, tap-exit holds until the window ends, auto off disables it', () async {
    final store = _MockDisplay();
    when(() => store.setBrightness(any())).thenAnswer((_) async {});
    final bloc = DisplayBloc(store);
    addTearDown(bloc.close);
    Future<void> add(DisplayEvent e) async {
      bloc.add(e);
      await pumpEventQueue();
    }

    await add(const DisplayNightManualSet(true));
    expect(bloc.state.night, isTrue);
    await add(const DisplayNightExited());
    expect(bloc.state.night, isFalse);

    await add(DisplayMinuteTicked(DateTime(2026, 1, 1, 23)));
    expect(bloc.state.night, isFalse); // exited: stays off inside the window
    await add(DisplayMinuteTicked(DateTime(2026, 1, 1, 12)));
    await add(DisplayMinuteTicked(DateTime(2026, 1, 1, 23)));
    expect(bloc.state.night, isTrue); // window ended and returned

    await add(const DisplayAutoSet(false));
    expect(bloc.state.night, isFalse);
  });
}

String hm2(int h, int m) => '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
