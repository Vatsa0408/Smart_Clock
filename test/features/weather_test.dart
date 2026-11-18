import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_clock/features/weather/weather_bloc.dart';
import 'package:smart_clock/features/weather/weather_store.dart';

class _MockStorage extends Mock implements Storage {}

void main() {
  test('parseOpenMeteo reads a real response', () {
    final j = jsonDecode(File('test/fixtures/open_meteo.json').readAsStringSync()) as Map<String, dynamic>;
    expect(parseOpenMeteo(j), const Weather(11, 'Rain', 11, 8));
  });

  test('storagePrefix is obfuscation-proof', () async {
    final storage = _MockStorage();
    when(() => storage.read(any())).thenReturn(null);
    HydratedBloc.storage = storage;
    final b = WeatherBloc(const SampleWeatherStore());
    expect(b.storagePrefix, 'WeatherBloc');
    await b.close();
  });

  test('a failed refresh retries on its own and recovers', () async {
    final storage = _MockStorage();
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
    final store = _FlakyStore(failures: 2);
    final b = WeatherBloc(store, retryBase: const Duration(milliseconds: 10))..add(const WeatherRequested());
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(store.calls, 3);
    expect(b.state.local, isNotNull);
    expect(b.state.error, isFalse);
    await b.close();
  });
}

class _FlakyStore extends SampleWeatherStore {
  _FlakyStore({required this.failures});
  int failures;
  int calls = 0;
  @override
  Future<Weather> local() async {
    calls++;
    if (failures-- > 0) throw const SocketException('offline');
    return super.local();
  }
}
