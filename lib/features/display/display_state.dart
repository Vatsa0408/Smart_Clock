part of 'display_bloc.dart';

final class DisplayState extends Equatable {
  const DisplayState({
    this.startMin = 22 * 60,
    this.endMin = 7 * 60,
    this.nightBrightness = 0.1,
    this.night = false,
    this.overheat = false,
    this.orbit = false,
    this.shift = 0,
  });

  /// Night window in minutes after midnight (may cross midnight).
  final int startMin;
  final int endMin;
  final double nightBrightness; // 0..1
  final bool night;
  final bool overheat;

  /// Burn-in orbit on, and the current position (0..7) in it.
  final bool orbit;
  final int shift;

  /// Dim and freeze animations: at night or when the battery is hot.
  bool get dim => night || overheat;

  DisplayState copyWith({int? startMin, int? endMin, double? nightBrightness, bool? night, bool? overheat, bool? orbit, int? shift}) =>
      DisplayState(
        startMin: startMin ?? this.startMin,
        endMin: endMin ?? this.endMin,
        nightBrightness: nightBrightness ?? this.nightBrightness,
        night: night ?? this.night,
        overheat: overheat ?? this.overheat,
        orbit: orbit ?? this.orbit,
        shift: shift ?? this.shift,
      );

  @override
  List<Object> get props => [startMin, endMin, nightBrightness, night, overheat, orbit, shift];
}
