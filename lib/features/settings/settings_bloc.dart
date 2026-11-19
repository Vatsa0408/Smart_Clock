import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'settings_store.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._store) : super(const SettingsState()) {
    on<SettingsNightScheduleChanged>(
      (e, emit) => emit(
        state.copyWith(
          nightStartMin: e.startMin,
          nightEndMin: e.endMin,
          nightBrightness: e.brightness?.clamp(0.02, 0.5),
        ),
      ),
    );
    on<SettingsLowBatteryChanged>(
      (e, emit) => emit(state.copyWith(lowBatteryPct: e.pct.clamp(5, 50))),
    );
    on<SettingsOverheatChanged>(
      (e, emit) => emit(state.copyWith(overheatC: e.c.clamp(38.0, 55.0))),
    );
    on<SettingsBurnInToggled>((e, emit) => emit(state.copyWith(burnInOrbit: e.on)));
    on<SettingsNightAutoToggled>((e, emit) => emit(state.copyWith(nightAuto: e.on)));
    on<SettingsKeepProtectToggled>((e, emit) => emit(state.copyWith(keepProtect: e.on)));
    on<SettingsAmbientToggled>((e, emit) => emit(state.copyWith(ambient: e.on)));
    on<SettingsHomeAppPickerOpened>((e, _) => _store.openHomeSettings());
    on<SettingsAndroidSettingsOpened>((e, _) => _store.openAndroidSettings());
  }

  final SettingsStore _store;

  @override
  String get storagePrefix => 'SettingsBloc';

  @override
  SettingsState? fromJson(Map<String, dynamic> json) =>
      SettingsState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(SettingsState state) => state.toJson();
}
