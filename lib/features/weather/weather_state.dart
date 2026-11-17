part of 'weather_bloc.dart';

final class WeatherState extends Equatable {
  const WeatherState({this.local, this.bangalore, this.fetchedAt, this.error = false});
  final Weather? local;
  final Weather? bangalore;
  final DateTime? fetchedAt;

  /// Last refresh failed; [local]/[bangalore] still hold the last good data.
  final bool error;

  WeatherState copyWith({bool? error}) => WeatherState(
        local: local,
        bangalore: bangalore,
        fetchedAt: fetchedAt,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props => [local, bangalore, fetchedAt, error];
}
