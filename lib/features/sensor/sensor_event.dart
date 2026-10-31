part of 'sensor_bloc.dart';

sealed class SensorEvent {
  const SensorEvent();
}

final class SensorRequested extends SensorEvent {
  const SensorRequested();
}
