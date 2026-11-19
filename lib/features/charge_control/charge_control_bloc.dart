import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'charge_control_store.dart';

part 'charge_control_event.dart';
part 'charge_control_state.dart';

/// Plain Bloc: the device is the source of truth, so it is read back on start (no hydration).
/// The low-battery alert and its chime live in DeviceBatteryBloc (one chime path).
class ChargeControlBloc extends Bloc<ChargeControlEvent, ChargeControlState> {
  ChargeControlBloc(this._store, {this.pollEvery = const Duration(minutes: 1), this.verifyAfter = const Duration(seconds: 20)})
      : super(const ChargeControlState()) {
    on<ChargeControlStarted>(_onStarted);
    on<ChargeControlBatteryChanged>(
      // ponytail: net current only; a "level not rising for 60 min" trend check can come later.
      (e, emit) => emit(state.copyWith(
        weakCharger: e.plugged && (e.level ?? 0) < 80 && e.currentMa != null && e.currentMa! <= 0,
      )),
    );
    on<ChargeControlProtectWanted>(_onWanted);
    on<ChargeControlAccessibilityOpened>((e, _) => _store.openAccessibility());
  }

  final ChargeControlStore _store;
  final Duration pollEvery, verifyAfter;

  Future<ChargeControlState> _read(ChargeControlState from) async {
    try {
      final on = await _store.protectOn();
      final svc = await _store.serviceEnabled();
      return from.copyWith(
        protectOn: on,
        serviceEnabled: svc,
        status: from.status == ProtectStatus.switching || from.status == ProtectStatus.failed
            ? from.status
            : (on == null ? ProtectStatus.unknown : ProtectStatus.ok),
      );
    } on Object catch (err) {
      debugPrint('Protect battery read failed: $err');
      return from;
    }
  }

  Future<void> _onStarted(ChargeControlStarted e, Emitter<ChargeControlState> emit) async {
    emit(await _read(state));
    if (state.protectOn == null) return; // Windows: nothing to poll
    await emit.forEach<ChargeControlState>(
      Stream.periodic(pollEvery).asyncMap((_) => _read(state)),
      onData: (s) => s,
    );
  }

  Future<void> _onWanted(ChargeControlProtectWanted e, Emitter<ChargeControlState> emit) async {
    if (!state.serviceEnabled) return emit(state.copyWith(status: ProtectStatus.serviceOff));
    emit(state.copyWith(status: ProtectStatus.switching));
    try {
      await _store.setProtect(e.on);
    } on Object catch (err) {
      debugPrint('Protect battery request failed: $err');
      return emit(state.copyWith(status: ProtectStatus.failed));
    }
    await Future<void>.delayed(verifyAfter); // on success Samsung reboots the tablet before this ends
    final on = await _store.protectOn();
    emit(state.copyWith(protectOn: on, status: on == e.on ? ProtectStatus.ok : ProtectStatus.failed));
  }
}
