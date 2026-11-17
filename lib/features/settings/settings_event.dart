part of 'settings_bloc.dart';

sealed class SettingsEvent {
  const SettingsEvent();
}

final class SettingsNightScheduleChanged extends SettingsEvent {
  const SettingsNightScheduleChanged({
    this.startMin,
    this.endMin,
    this.brightness,
  });
  final int? startMin, endMin;
  final double? brightness;
}

final class SettingsLowBatteryChanged extends SettingsEvent {
  const SettingsLowBatteryChanged(this.pct);
  final int pct;
}

final class SettingsOverheatChanged extends SettingsEvent {
  const SettingsOverheatChanged(this.c);
  final double c;
}

final class SettingsHomeAppPickerOpened extends SettingsEvent {
  const SettingsHomeAppPickerOpened();
}

final class SettingsAndroidSettingsOpened extends SettingsEvent {
  const SettingsAndroidSettingsOpened();
}
