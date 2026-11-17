import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_clock/features/weather/weather_store.dart';

void main() {
  test('parseOpenMeteo reads a real response', () {
    final j = jsonDecode(File('test/fixtures/open_meteo.json').readAsStringSync()) as Map<String, dynamic>;
    expect(parseOpenMeteo(j), const Weather(11, 'Rain', 11, 8));
  });
}
