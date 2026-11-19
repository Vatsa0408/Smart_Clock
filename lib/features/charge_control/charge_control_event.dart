part of 'charge_control_bloc.dart';

sealed class ChargeControlEvent {
  const ChargeControlEvent();
}

/// Reads the device state and then re-reads it every minute.
final class ChargeControlStarted extends ChargeControlEvent {
  const ChargeControlStarted();
}

final class ChargeControlBatteryChanged extends ChargeControlEvent {
  const ChargeControlBatteryChanged({required this.level, required this.plugged, required this.currentMa});
  final int? level;
  final bool plugged;
  final int? currentMa;
}

/// User tapped Fix (after the reboot confirm dialog).
final class ChargeControlProtectWanted extends ChargeControlEvent {
  const ChargeControlProtectWanted(this.on);
  final bool on;
}

final class ChargeControlAccessibilityOpened extends ChargeControlEvent {
  const ChargeControlAccessibilityOpened();
}
