part of 'display_bloc.dart';

sealed class DisplayEvent {
  const DisplayEvent();
}

final class DisplayMinuteTicked extends DisplayEvent {
  const DisplayMinuteTicked(this.now);
  final DateTime now;
}

final class DisplayScheduleSet extends DisplayEvent {
  const DisplayScheduleSet(this.startMin, this.endMin, this.nightBrightness);
  final int startMin, endMin;
  final double nightBrightness;
}

final class DisplayOrbitSet extends DisplayEvent {
  const DisplayOrbitSet(this.on);
  final bool on;
}

final class DisplayOverheatChanged extends DisplayEvent {
  const DisplayOverheatChanged(this.on);
  final bool on;
}

final class DisplayAutoSet extends DisplayEvent {
  const DisplayAutoSet(this.on);
  final bool on;
}

/// Night mode switched on by hand (night panel).
final class DisplayNightManualSet extends DisplayEvent {
  const DisplayNightManualSet(this.on);
  final bool on;
}

/// Tap on the night overlay: leave night mode until the window ends.
final class DisplayNightExited extends DisplayEvent {
  const DisplayNightExited();
}
