part of 'settings_bloc.dart';

final class SettingsState extends Equatable {
  const SettingsState({
    this.nightStartMin = 22 * 60,
    this.nightEndMin = 7 * 60,
    this.nightBrightness = 0.1,
    this.lowBatteryPct = 20,
    this.overheatC = 45.0,
    this.burnInOrbit = true,
    this.nightAuto = true,
    this.ambient = true,
    this.keepProtect = true,
  });

  final int nightStartMin, nightEndMin, lowBatteryPct;
  final double nightBrightness;
  final double overheatC;
  final bool burnInOrbit;

  /// Night mode starts by itself in the window / dims with room light (stored only: no light-sensor source yet).
  final bool nightAuto, ambient;

  /// Keep Samsung Protect battery (85 % hold) ON; the alert level reuses [lowBatteryPct].
  final bool keepProtect;

  SettingsState copyWith({
    int? nightStartMin,
    int? nightEndMin,
    double? nightBrightness,
    int? lowBatteryPct,
    double? overheatC,
    bool? burnInOrbit,
    bool? nightAuto,
    bool? ambient,
    bool? keepProtect,
  }) => SettingsState(
    nightStartMin: nightStartMin ?? this.nightStartMin,
    nightEndMin: nightEndMin ?? this.nightEndMin,
    nightBrightness: nightBrightness ?? this.nightBrightness,
    lowBatteryPct: lowBatteryPct ?? this.lowBatteryPct,
    overheatC: overheatC ?? this.overheatC,
    burnInOrbit: burnInOrbit ?? this.burnInOrbit,
    nightAuto: nightAuto ?? this.nightAuto,
    ambient: ambient ?? this.ambient,
    keepProtect: keepProtect ?? this.keepProtect,
  );

  /// Primitives only, and never secrets (bindkeys, tokens): those go to a file.
  Map<String, Object> toJson() => {
    'ns': nightStartMin,
    'ne': nightEndMin,
    'nb': nightBrightness,
    'lb': lowBatteryPct,
    'oh': overheatC,
    'bo': burnInOrbit,
    'na': nightAuto,
    'am': ambient,
    'cp': keepProtect,
  };

  /// Each key falls back to its default, so adding fields later needs no migration.
  factory SettingsState.fromJson(Map<String, dynamic> j) => SettingsState(
    nightStartMin: (j['ns'] as num?)?.toInt() ?? 22 * 60,
    nightEndMin: (j['ne'] as num?)?.toInt() ?? 7 * 60,
    nightBrightness: (j['nb'] as num?)?.toDouble() ?? 0.1,
    lowBatteryPct: (j['lb'] as num?)?.toInt() ?? 20,
    overheatC: (j['oh'] as num?)?.toDouble() ?? 45.0,
    burnInOrbit: j['bo'] as bool? ?? true,
    nightAuto: j['na'] as bool? ?? true,
    ambient: j['am'] as bool? ?? true,
    keepProtect: j['cp'] as bool? ?? true,
  );

  @override
  List<Object> get props => [
    nightStartMin,
    nightEndMin,
    nightBrightness,
    lowBatteryPct,
    overheatC,
    burnInOrbit,
    nightAuto,
    ambient,
    keepProtect,
  ];
}
