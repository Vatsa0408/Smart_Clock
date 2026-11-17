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
}
