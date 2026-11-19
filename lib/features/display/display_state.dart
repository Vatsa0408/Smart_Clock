part of 'display_bloc.dart';

final class DisplayState extends Equatable {
  const DisplayState({
    this.startMin = 22 * 60,
    this.endMin = 7 * 60,
    this.nightBrightness = 0.1,
    this.inWin = false,
    this.auto = true,
    this.manual = false,
    this.suppressed = false,
    this.overheat = false,
    this.orbit = false,
    this.shift = 0,
  });

  /// Night window in minutes after midnight (may cross midnight).
  final int startMin;
  final int endMin;
  final double nightBrightness; // 0..1
  /// Clock is inside the night window (raw schedule).
  final bool inWin;

  /// Auto night mode on, manual night on, and "exited by tap until the window ends".
  final bool auto, manual, suppressed;
  final bool overheat;

  /// Burn-in orbit on, and the current position (0..7) in it.
  final bool orbit;
  final int shift;

  /// Night overlay + dimming: manual, or auto inside the window unless exited by tap.
  bool get night => manual || (auto && inWin && !suppressed);

  /// Dim and freeze animations: at night or when the battery is hot.
  bool get dim => night || overheat;

  DisplayState copyWith({
    int? startMin,
    int? endMin,
    double? nightBrightness,
    bool? inWin,
    bool? auto,
    bool? manual,
    bool? suppressed,
    bool? overheat,
    bool? orbit,
    int? shift,
  }) =>
      DisplayState(
        startMin: startMin ?? this.startMin,
        endMin: endMin ?? this.endMin,
        nightBrightness: nightBrightness ?? this.nightBrightness,
        inWin: inWin ?? this.inWin,
        auto: auto ?? this.auto,
        manual: manual ?? this.manual,
        suppressed: suppressed ?? this.suppressed,
        overheat: overheat ?? this.overheat,
        orbit: orbit ?? this.orbit,
        shift: shift ?? this.shift,
      );

  @override
  List<Object> get props => [startMin, endMin, nightBrightness, inWin, auto, manual, suppressed, overheat, orbit, shift];
}
