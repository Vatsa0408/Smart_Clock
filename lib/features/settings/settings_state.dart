part of 'settings_bloc.dart';

final class SettingsState extends Equatable {
  const SettingsState({
    this.nightStartMin = 22 * 60,
    this.nightEndMin = 7 * 60,
    this.nightBrightness = 0.1,
    this.lowBatteryPct = 20,
  });

  final int nightStartMin, nightEndMin, lowBatteryPct;
  final double nightBrightness;

  SettingsState copyWith({int? nightStartMin, int? nightEndMin, double? nightBrightness, int? lowBatteryPct}) =>
      SettingsState(
        nightStartMin: nightStartMin ?? this.nightStartMin,
        nightEndMin: nightEndMin ?? this.nightEndMin,
        nightBrightness: nightBrightness ?? this.nightBrightness,
        lowBatteryPct: lowBatteryPct ?? this.lowBatteryPct,
      );

  /// Primitives only, and never secrets (bindkeys, tokens): those go to a file.
  Map<String, Object> toJson() =>
      {'ns': nightStartMin, 'ne': nightEndMin, 'nb': nightBrightness, 'lb': lowBatteryPct};

  /// Each key falls back to its default, so adding fields later needs no migration.
  factory SettingsState.fromJson(Map<String, dynamic> j) => SettingsState(
        nightStartMin: (j['ns'] as num?)?.toInt() ?? 22 * 60,
        nightEndMin: (j['ne'] as num?)?.toInt() ?? 7 * 60,
        nightBrightness: (j['nb'] as num?)?.toDouble() ?? 0.1,
        lowBatteryPct: (j['lb'] as num?)?.toInt() ?? 20,
      );

  @override
  List<Object> get props => [nightStartMin, nightEndMin, nightBrightness, lowBatteryPct];
}
