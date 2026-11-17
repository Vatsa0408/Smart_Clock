part of 'display_bloc.dart';

final class DisplayState extends Equatable {
  const DisplayState({
    this.startMin = 22 * 60,
    this.endMin = 7 * 60,
    this.nightBrightness = 0.1,
    this.night = false,
  });

  /// Night window in minutes after midnight (may cross midnight).
  final int startMin;
  final int endMin;
  final double nightBrightness; // 0..1
  final bool night;

  DisplayState copyWith({bool? night}) => DisplayState(
        startMin: startMin,
        endMin: endMin,
        nightBrightness: nightBrightness,
        night: night ?? this.night,
      );

  @override
  List<Object> get props => [startMin, endMin, nightBrightness, night];
}
