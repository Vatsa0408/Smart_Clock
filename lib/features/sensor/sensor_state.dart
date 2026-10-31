part of 'sensor_bloc.dart';

final class SensorState extends Equatable {
  const SensorState({this.reading});
  final SensorReading? reading;

  @override
  List<Object?> get props => [reading];
}
