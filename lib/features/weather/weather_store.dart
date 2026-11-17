import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';

final class Weather extends Equatable {
  const Weather(this.temp, this.condition, this.high, this.low);
  final int temp;
  final String condition;
  final int high;
  final int low;

  factory Weather.fromJson(Map<String, dynamic> j) =>
      Weather(j['t'] as int, j['c'] as String, j['h'] as int, j['l'] as int);

  Map<String, Object> toJson() => {'t': temp, 'c': condition, 'h': high, 'l': low};

  @override
  List<Object> get props => [temp, condition, high, low];
}

/// Swap in a real source (Open-Meteo, Home Assistant) by implementing this.
abstract interface class WeatherStore {
  Future<Weather> local();
  Future<Weather> bangalore();
}

class SampleWeatherStore implements WeatherStore {
  const SampleWeatherStore();
  @override
  Future<Weather> local() async => const Weather(14, 'Partly cloudy', 16, 8);
  @override
  Future<Weather> bangalore() async => const Weather(27, 'Light rain', 29, 20);
}

/// Open-Meteo (no API key). "Local" is Kempten, Germany.
class OpenMeteoWeatherStore implements WeatherStore {
  const OpenMeteoWeatherStore();
  static final _http = HttpClient()..connectionTimeout = const Duration(seconds: 10);

  @override
  Future<Weather> local() => _fetch(47.7267, 10.3139);
  @override
  Future<Weather> bangalore() => _fetch(12.97, 77.59);

  Future<Weather> _fetch(double lat, double lon) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$lat',
      'longitude': '$lon',
      'current': 'temperature_2m,weather_code',
      'daily': 'temperature_2m_max,temperature_2m_min',
      'timezone': 'auto',
      'forecast_days': '1',
    });
    final res = await (await _http.getUrl(uri)).close().timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw HttpException('open-meteo ${res.statusCode}', uri: uri);
    return parseOpenMeteo(jsonDecode(await res.transform(utf8.decoder).join()) as Map<String, dynamic>);
  }
}

Weather parseOpenMeteo(Map<String, dynamic> j) {
  final c = j['current'] as Map<String, dynamic>, d = j['daily'] as Map<String, dynamic>;
  return Weather(
    (c['temperature_2m'] as num).round(),
    wmoLabel(c['weather_code'] as int),
    ((d['temperature_2m_max'] as List)[0] as num).round(),
    ((d['temperature_2m_min'] as List)[0] as num).round(),
  );
}

String wmoLabel(int code) => switch (code) {
      0 => 'Clear',
      1 || 2 => 'Partly cloudy',
      3 => 'Overcast',
      45 || 48 => 'Fog',
      >= 51 && <= 57 => 'Drizzle',
      >= 61 && <= 67 => 'Rain',
      >= 71 && <= 77 => 'Snow',
      >= 80 && <= 82 => 'Showers',
      85 || 86 => 'Snow showers',
      >= 95 => 'Thunderstorm',
      _ => 'Unknown',
    };
