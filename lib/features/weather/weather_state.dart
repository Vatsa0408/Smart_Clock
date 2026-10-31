part of 'weather_bloc.dart';

final class WeatherState extends Equatable {
  const WeatherState({this.local, this.bangalore});
  final Weather? local;
  final Weather? bangalore;

  @override
  List<Object?> get props => [local, bangalore];
}
