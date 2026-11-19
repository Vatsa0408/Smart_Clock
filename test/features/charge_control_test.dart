import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_clock/features/charge_control/charge_control_bloc.dart';
import 'package:smart_clock/features/charge_control/charge_control_store.dart';
import 'package:smart_clock/features/device_battery/device_battery_bloc.dart';

class _MockStore extends Mock implements ChargeControlStore {}

void main() {
  test('lowAlert: enter at <= 20 unplugged, hysteresis to 23, plugged or null clears', () {
    bool a(int? l, {bool plugged = false, bool cur = false}) =>
        lowAlert(level: l, plugged: plugged, alertPct: 20, current: cur);
    expect(a(20), isTrue);
    expect(a(21), isFalse);
    expect(a(23, cur: true), isTrue);
    expect(a(24, cur: true), isFalse);
    expect(a(10, plugged: true), isFalse);
    expect(a(null), isFalse);
  });

  group('ChargeControlBloc', () {
    late _MockStore store;
    late ChargeControlBloc bloc;

    setUp(() {
      store = _MockStore();
      when(() => store.protectOn()).thenAnswer((_) async => false);
      when(() => store.serviceEnabled()).thenAnswer((_) async => true);
      when(() => store.setProtect(any())).thenAnswer((_) async {});
      bloc = ChargeControlBloc(store, pollEvery: const Duration(hours: 1), verifyAfter: Duration.zero);
    });
    tearDown(() => bloc.close());

    test('started reads the device state', () async {
      bloc.add(const ChargeControlStarted());
      await pumpEventQueue();
      expect(bloc.state.protectOn, isFalse);
      expect(bloc.state.serviceEnabled, isTrue);
      expect(bloc.state.status, ProtectStatus.ok);
    });

    test('Windows (null store): no crash, no state', () async {
      when(() => store.protectOn()).thenAnswer((_) async => null);
      when(() => store.serviceEnabled()).thenAnswer((_) async => false);
      bloc.add(const ChargeControlStarted());
      bloc.add(const ChargeControlBatteryChanged(level: 10, plugged: false, currentMa: null));
      await pumpEventQueue();
      expect(bloc.state.protectOn, isNull);
      expect(bloc.state.weakCharger, isFalse);
    });

    test('wanted with the service off asks for the service, never launches Settings', () async {
      when(() => store.serviceEnabled()).thenAnswer((_) async => false);
      bloc.add(const ChargeControlStarted());
      await pumpEventQueue();
      bloc.add(const ChargeControlProtectWanted(true));
      await pumpEventQueue();
      expect(bloc.state.status, ProtectStatus.serviceOff);
      verifyNever(() => store.setProtect(any()));
    });

    test('wanted that did not show up in the system value -> failed', () async {
      bloc.add(const ChargeControlStarted());
      await pumpEventQueue();
      bloc.add(const ChargeControlProtectWanted(true));
      await pumpEventQueue();
      expect(bloc.state.status, ProtectStatus.failed);
    });

    test('wanted that shows up -> ok', () async {
      bloc.add(const ChargeControlStarted());
      await pumpEventQueue();
      when(() => store.protectOn()).thenAnswer((_) async => true);
      bloc.add(const ChargeControlProtectWanted(true));
      await pumpEventQueue();
      expect(bloc.state.status, ProtectStatus.ok);
      expect(bloc.state.protectOn, isTrue);
    });

    test('store failure -> failed', () async {
      bloc.add(const ChargeControlStarted());
      await pumpEventQueue();
      when(() => store.setProtect(any())).thenThrow(PlatformException(code: 'launch'));
      bloc.add(const ChargeControlProtectWanted(true));
      await pumpEventQueue();
      expect(bloc.state.status, ProtectStatus.failed);
    });

    test('weak charger: plugged, below 80 and net current <= 0', () async {
      bloc.add(const ChargeControlBatteryChanged(level: 50, plugged: true, currentMa: -120));
      await pumpEventQueue();
      expect(bloc.state.weakCharger, isTrue);
      bloc.add(const ChargeControlBatteryChanged(level: 50, plugged: true, currentMa: 400));
      await pumpEventQueue();
      expect(bloc.state.weakCharger, isFalse);
    });
  });
}
