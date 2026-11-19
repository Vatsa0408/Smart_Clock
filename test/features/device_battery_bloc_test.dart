import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_clock/features/device_battery/device_battery_bloc.dart';
import 'package:smart_clock/features/device_battery/device_battery_store.dart';

class _MockStore extends Mock implements DeviceBatteryStore {}

BatterySample _s(int level, {bool charging = false, double? t, bool hot = false}) =>
    (level: level, charging: charging, plugged: charging, currentMa: null, tempC: t, healthOverheat: hot);

void main() {
  late _MockStore store;
  late StreamController<BatterySample> updates;
  late DeviceBatteryBloc bloc;

  setUp(() {
    store = _MockStore();
    updates = StreamController<BatterySample>.broadcast();
    when(() => store.updates).thenAnswer((_) => updates.stream);
    when(() => store.playSound(any())).thenAnswer((_) async {});
  });

  Future<void> start(BatterySample? first) async {
    when(() => store.read()).thenAnswer((_) async => first);
    bloc = DeviceBatteryBloc(store)..add(const DeviceBatteryRequested());
    await pumpEventQueue();
  }

  Future<void> push(BatterySample s) async {
    updates.add(s);
    await pumpEventQueue();
  }

  tearDown(() async {
    await bloc.close();
    await updates.close();
  });

  test('read() null (Windows): nothing emitted', () async {
    await start(null);
    expect(bloc.state, const DeviceBatteryState());
  });

  test('startup at 15% is low but never chimes', () async {
    await start(_s(15));
    expect(bloc.state.low, isTrue);
    verifyNever(() => store.playSound(any()));
  });

  test('25 -> 19 -> 18 -> 30 -> 19 chimes exactly twice', () async {
    await start(_s(25));
    for (final l in [19, 18, 30, 19]) {
      await push(_s(l));
    }
    verify(() => store.playSound('low_battery')).called(2);
  });

  test('no low chime at night', () async {
    await start(_s(25));
    bloc.add(const DeviceBatteryNightChanged(true));
    await push(_s(19));
    verifyNever(() => store.playSound(any()));
  });

  test('threshold change applies to the next sample', () async {
    await start(_s(40));
    bloc.add(const DeviceBatteryThresholdsSet(30, 45));
    await push(_s(28));
    expect(bloc.state.low, isTrue);
  });

  test('overheat has 2 degree hysteresis and chimes once', () async {
    await start(_s(80, t: 30));
    final seen = <bool>[];
    for (final t in [44.0, 45.0, 44.0, 42.9]) {
      await push(_s(80, t: t));
      seen.add(bloc.state.overheat);
    }
    expect(seen, [false, true, true, false]);
    verify(() => store.playSound('overheat')).called(1);
  });

  test('health overheat flag wins at 30 C', () async {
    await start(_s(80, t: 30));
    await push(_s(80, t: 30, hot: true));
    expect(bloc.state.overheat, isTrue);
  });

  test('low alert holds until 4% above the threshold and clears when plugged', () async {
    await start(_s(25));
    final seen = <bool>[];
    for (final l in [20, 23, 24]) {
      await push(_s(l));
      seen.add(bloc.state.low);
    }
    await push(_s(10));
    await push(_s(10, charging: true));
    seen.add(bloc.state.low);
    expect(seen, [true, true, false, false]);
  });
}
