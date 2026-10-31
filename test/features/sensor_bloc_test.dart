import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_clock/features/sensor/sensor_bloc.dart';
import 'package:smart_clock/features/sensor/sensor_store.dart';

class _MockStorage extends Mock implements Storage {}

/// Nothing configured, like a fresh checkout without sensors.json.
class _EmptyStore extends SampleSensorStore {
  const _EmptyStore();
  @override
  Future<Map<String, SensorConfig>> loadConfig() async => {};
}

void main() {
  setUp(() {
    final storage = _MockStorage();
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  blocTest<SensorBloc, SensorState>(
    'configured rooms receive readings',
    build: () => SensorBloc(const SampleSensorStore()),
    act: (b) => b.add(const SensorRequested()),
    wait: const Duration(milliseconds: 50),
    verify: (b) {
      expect(b.state.rooms.map((r) => r.name), ['Living Room', 'Bedroom', 'Bathroom']);
      expect(b.state.rooms.every((r) => r.temperature == 22.4 && r.seenAt != null), isTrue);
    },
  );

  blocTest<SensorBloc, SensorState>(
    'unconfigured rooms keep no reading',
    build: () => SensorBloc(const _EmptyStore()),
    act: (b) => b.add(const SensorRequested()),
    verify: (b) => expect(b.state.rooms.every((r) => r.temperature == null), isTrue),
  );
}
