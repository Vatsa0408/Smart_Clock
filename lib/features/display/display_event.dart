part of 'display_bloc.dart';

sealed class DisplayEvent {
  const DisplayEvent();
}

final class DisplayMinuteTicked extends DisplayEvent {
  const DisplayMinuteTicked(this.now);
  final DateTime now;
}
