part of 'device_battery_bloc.dart';

sealed class DeviceBatteryEvent {
  const DeviceBatteryEvent();
}

final class DeviceBatteryRequested extends DeviceBatteryEvent {
  const DeviceBatteryRequested();
}

final class DeviceBatteryThresholdsSet extends DeviceBatteryEvent {
  const DeviceBatteryThresholdsSet(this.lowPct, this.overheatC);
  final int lowPct;
  final double overheatC;
}

final class DeviceBatteryNightChanged extends DeviceBatteryEvent {
  const DeviceBatteryNightChanged(this.night);
  final bool night;
}
