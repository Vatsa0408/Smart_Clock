import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_clock/features/settings/settings_bloc.dart';
import 'package:smart_clock/features/settings/settings_store.dart';

class _MockStorage extends Mock implements Storage {}

void main() {
  late SettingsBloc bloc;

  setUp(() {
    final storage = _MockStorage();
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
    bloc = SettingsBloc(const SettingsStore());
  });
  tearDown(() => bloc.close());

  test('defaults and storagePrefix', () {
    expect(bloc.state, const SettingsState());
    expect(bloc.state.nightStartMin, 1320);
    expect(bloc.state.nightEndMin, 420);
    expect(bloc.storagePrefix, 'SettingsBloc');
  });

  test('events clamp, and a partial schedule keeps the rest', () async {
    bloc.add(const SettingsNightScheduleChanged(brightness: 0.9));
    bloc.add(const SettingsLowBatteryChanged(2));
    bloc.add(const SettingsOverheatChanged(99));
    bloc.add(const SettingsNightScheduleChanged(startMin: 1380));
    await pumpEventQueue();
    expect(bloc.state.nightBrightness, 0.5);
    expect(bloc.state.lowBatteryPct, 5);
    expect(bloc.state.overheatC, 55);
    expect(bloc.state.nightStartMin, 1380);
    expect(bloc.state.nightEndMin, 420);
  });

  test('json round-trips, empty json gives defaults, keys are an allow-list (no secrets)', () {
    const s = SettingsState(
      nightStartMin: 1,
      nightEndMin: 2,
      nightBrightness: 0.3,
      lowBatteryPct: 33,
      overheatC: 50,
    );
    expect(SettingsState.fromJson(s.toJson()), s);
    expect(SettingsState.fromJson({}), const SettingsState());
    expect(const SettingsState().toJson().keys.toSet(), {
      'ns',
      'ne',
      'nb',
      'lb',
      'oh',
    });
  });
}
