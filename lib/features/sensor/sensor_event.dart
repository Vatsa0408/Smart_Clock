part of 'sensor_bloc.dart';

sealed class SensorEvent {
  const SensorEvent();
}

/// Loads the room config and starts listening for readings.
final class SensorRequested extends SensorEvent {
  const SensorRequested();
}
