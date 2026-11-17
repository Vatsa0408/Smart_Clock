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

final class DisplayOverheatChanged extends DisplayEvent {
  const DisplayOverheatChanged(this.on);
  final bool on;
}
