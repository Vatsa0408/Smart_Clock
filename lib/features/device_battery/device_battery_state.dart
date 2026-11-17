part of 'device_battery_bloc.dart';

final class DeviceBatteryState extends Equatable {
  const DeviceBatteryState({
    this.level,
    this.isCharging = false,
    this.tempC,
    this.low = false,
    this.overheat = false,
    this.lowPct = 20,
    this.overheatC = 45.0,
    this.night = false,
  });

  final int? level;
  final bool isCharging;
  final double? tempC;
  final bool low;
  final bool overheat;
  final int lowPct;
  final double overheatC;
  final bool night;

  DeviceBatteryState copyWith({
    int? level,
    bool? isCharging,
    double? tempC,
    bool? low,
    bool? overheat,
    int? lowPct,
    double? overheatC,
    bool? night,
  }) =>
      DeviceBatteryState(
        level: level ?? this.level,
        isCharging: isCharging ?? this.isCharging,
        tempC: tempC ?? this.tempC,
        low: low ?? this.low,
        overheat: overheat ?? this.overheat,
        lowPct: lowPct ?? this.lowPct,
        overheatC: overheatC ?? this.overheatC,
        night: night ?? this.night,
      );

  @override
  List<Object?> get props => [level, isCharging, tempC, low, overheat, lowPct, overheatC, night];
}
