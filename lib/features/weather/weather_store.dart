import 'package:equatable/equatable.dart';

final class Weather extends Equatable {
  const Weather(this.temp, this.condition, this.high, this.low);
  final int temp;
  final String condition;
  final int high;
  final int low;

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
