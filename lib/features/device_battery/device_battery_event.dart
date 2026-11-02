import 'package:equatable/equatable.dart';

abstract class DeviceBatteryEvent extends Equatable {
  const DeviceBatteryEvent();

  @override
  List<Object?> get props => [];
}

class DeviceBatteryRequested extends DeviceBatteryEvent {
  const DeviceBatteryRequested();

  @override
  List<Object?> get props => [];
}

class DeviceBatteryUpdated extends DeviceBatteryEvent {
  const DeviceBatteryUpdated({required this.level, this.isCharging = false});
  final int level;
  final bool isCharging;

  @override
  List<Object?> get props => [level, isCharging];
}