import 'package:equatable/equatable.dart';

class DeviceBatteryState extends Equatable {
  const DeviceBatteryState({this.level, this.isCharging = false});
  final int? level;
  final bool isCharging;

  @override
  List<Object?> get props => [level, isCharging];
}