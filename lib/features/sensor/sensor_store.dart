import 'package:equatable/equatable.dart';

final class SensorReading extends Equatable {
  const SensorReading(this.temperature, this.humidity);
  final double temperature;
  final int humidity;

  @override
  List<Object> get props => [temperature, humidity];
}

/// Replace with a real Xiaomi Temperature Sensor 2 source later.
abstract interface class SensorStore {
  Future<SensorReading> read();
}

class SampleSensorStore implements SensorStore {
  const SampleSensorStore();
  @override
  Future<SensorReading> read() async => const SensorReading(22.4, 48);
}
