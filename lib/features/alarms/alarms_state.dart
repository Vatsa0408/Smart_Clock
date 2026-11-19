part of 'alarms_bloc.dart';

final class AlarmsState extends Equatable {
  const AlarmsState({
    this.alarms = defaultAlarms,
    this.editing,
    this.ringing,
    this.preview = false,
    this.snoozed,
    this.snoozeAt,
  });

  final List<Alarm> alarms;

  /// Draft in the editor (id null = new). Not persisted.
  final Alarm? editing;

  /// Alarm currently ringing; [preview] = triggered from the editor.
  final Alarm? ringing;
  final bool preview;
  final Alarm? snoozed;
  final DateTime? snoozeAt;

  static const maxAlarms = 4;

  /// Nullable fields take a closure so they can be set back to null.
  AlarmsState copyWith({
    List<Alarm>? alarms,
    Alarm? Function()? editing,
    Alarm? Function()? ringing,
    bool? preview,
    Alarm? Function()? snoozed,
    DateTime? Function()? snoozeAt,
  }) =>
      AlarmsState(
        alarms: alarms ?? this.alarms,
        editing: editing != null ? editing() : this.editing,
        ringing: ringing != null ? ringing() : this.ringing,
        preview: preview ?? this.preview,
        snoozed: snoozed != null ? snoozed() : this.snoozed,
        snoozeAt: snoozeAt != null ? snoozeAt() : this.snoozeAt,
      );

  @override
  List<Object?> get props => [alarms, editing, ringing, preview, snoozed, snoozeAt];
}
