part of 'weather_bloc.dart';

sealed class WeatherEvent {
  const WeatherEvent();
}

final class WeatherRequested extends WeatherEvent {
  const WeatherRequested();
}
