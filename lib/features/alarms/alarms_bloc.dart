import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'alarms_store.dart';

part 'alarms_event.dart';
part 'alarms_state.dart';

class AlarmsBloc extends HydratedBloc<AlarmsEvent, AlarmsState> {
  AlarmsBloc() : super(const AlarmsState()) {
    on<AlarmToggled>((e, emit) => emit(state.copyWith(
          alarms: [for (final a in state.alarms) a.id == e.id ? a.copyWith(on: !a.on) : a],
        )));
    on<AlarmEditStarted>((e, emit) => emit(state.copyWith(editing: () => e.alarm ?? const Alarm())));
    on<AlarmDraftChanged>((e, emit) => emit(state.copyWith(editing: () => e.draft)));
    on<AlarmEditCancelled>((e, emit) => emit(state.copyWith(editing: () => null)));
    on<AlarmSaved>((e, emit) {
      final d = state.editing;
      if (d == null) return;
      final a = d.copyWith(label: d.label.trim().isEmpty ? 'Alarm' : d.label.trim());
      final list = a.id == null
          ? [...state.alarms, a.copyWith(id: DateTime.now().millisecondsSinceEpoch)]
          : [for (final x in state.alarms) x.id == a.id ? a : x];
      emit(state.copyWith(alarms: list, editing: () => null));
    });
    on<AlarmDeleted>((e, emit) => emit(state.copyWith(
          alarms: state.alarms.where((a) => a.id != state.editing?.id).toList(),
          editing: () => null,
        )));
    on<AlarmPreviewed>((e, emit) {
      if (state.editing != null) emit(state.copyWith(ringing: () => state.editing, preview: true));
    });
    on<AlarmMinuteTicked>((e, emit) {
      if (state.ringing != null) return;
      final n = e.now;
      final hit = state.alarms.where((a) => a.on && a.h == n.hour && a.m == n.minute && a.firesOn(n.weekday - 1));
      if (hit.isNotEmpty) {
        final a = hit.first;
        emit(state.copyWith(
          ringing: () => a,
          preview: false,
          // A one-shot alarm switches itself off.
          alarms: a.noDays ? [for (final x in state.alarms) x.id == a.id ? x.copyWith(on: false) : x] : null,
        ));
      } else if (state.snoozeAt case final at? when !n.isBefore(at)) {
        emit(state.copyWith(ringing: () => state.snoozed, preview: false, snoozed: () => null, snoozeAt: () => null));
      }
    });
    on<AlarmSnoozed>((e, emit) {
      final r = state.ringing;
      if (r == null) return;
      if (state.preview) return emit(state.copyWith(ringing: () => null, preview: false));
      final t = e.now.add(Duration(minutes: r.snooze));
      emit(state.copyWith(
        ringing: () => null,
        snoozed: () => r,
        snoozeAt: () => DateTime(t.year, t.month, t.day, t.hour, t.minute),
      ));
    });
    on<AlarmDismissed>((e, emit) =>
        emit(state.copyWith(ringing: () => null, preview: false, snoozed: () => null, snoozeAt: () => null)));
  }

  @override
  String get storagePrefix => 'AlarmsBloc';

  @override
  AlarmsState? fromJson(Map<String, dynamic> json) => AlarmsState(
        alarms: [for (final a in json['alarms'] as List) Alarm.fromJson(a as Map<String, dynamic>)],
      );

  @override
  Map<String, dynamic>? toJson(AlarmsState state) => {'alarms': [for (final a in state.alarms) a.toJson()]};
}
