part of 'sensor_bloc.dart';

final class SensorState extends Equatable {
  const SensorState({this.rooms = const [
    RoomSensor('Living Room'),
    RoomSensor('Bedroom'),
    RoomSensor('Bathroom'),
  ]});

  final List<RoomSensor> rooms;

  @override
  List<Object?> get props => [rooms];
}
