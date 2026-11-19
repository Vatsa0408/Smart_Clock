part of 'alarms_bloc.dart';

sealed class AlarmsEvent {
  const AlarmsEvent();
}

final class AlarmToggled extends AlarmsEvent {
  const AlarmToggled(this.id);
  final int id;
}

/// [alarm] null starts a new alarm.
final class AlarmEditStarted extends AlarmsEvent {
  const AlarmEditStarted([this.alarm]);
  final Alarm? alarm;
}

final class AlarmDraftChanged extends AlarmsEvent {
  const AlarmDraftChanged(this.draft);
  final Alarm draft;
}

final class AlarmSaved extends AlarmsEvent {
  const AlarmSaved();
}

final class AlarmDeleted extends AlarmsEvent {
  const AlarmDeleted();
}

final class AlarmEditCancelled extends AlarmsEvent {
  const AlarmEditCancelled();
}

final class AlarmPreviewed extends AlarmsEvent {
  const AlarmPreviewed();
}

/// Once a minute: fires matching alarms and due snoozes.
final class AlarmMinuteTicked extends AlarmsEvent {
  const AlarmMinuteTicked(this.now);
  final DateTime now;
}

final class AlarmSnoozed extends AlarmsEvent {
  const AlarmSnoozed(this.now);
  final DateTime now;
}

final class AlarmDismissed extends AlarmsEvent {
  const AlarmDismissed();
}
