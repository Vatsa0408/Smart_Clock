import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'device_battery_store.dart';

part 'device_battery_event.dart';
part 'device_battery_state.dart';

/// Low-battery alert with hysteresis: enters at <= [alertPct] unplugged, leaves when plugged or above [alertPct] + 3.
bool lowAlert({required int? level, required bool plugged, required int alertPct, required bool current}) =>
    level != null && !plugged && (level <= alertPct || (current && level <= alertPct + 3));

class DeviceBatteryBloc extends Bloc<DeviceBatteryEvent, DeviceBatteryState> {
  DeviceBatteryBloc(this._store) : super(const DeviceBatteryState()) {
    on<DeviceBatteryRequested>(_onRequested);
    on<DeviceBatteryThresholdsSet>(
        (e, emit) => emit(state.copyWith(lowPct: e.lowPct, overheatC: e.overheatC)));
    on<DeviceBatteryNightChanged>((e, emit) => emit(state.copyWith(night: e.night)));
  }

  final DeviceBatteryStore _store;
  DateTime? _lastChime;

  Future<void> _onRequested(DeviceBatteryRequested e, Emitter<DeviceBatteryState> emit) async {
    try {
      final first = await _store.read();
      if (first == null) return; // Windows: the indicator stays hidden
      emit(_next(first, sound: false)); // no chime at startup
    } on PlatformException catch (err) {
      debugPrint('Battery read failed: ${err.message}');
    }
    await emit.forEach<BatterySample>(_store.updates, onData: (s) => _next(s));
  }

  DeviceBatteryState _next(BatterySample s, {bool sound = true}) {
    final low = lowAlert(level: s.level, plugged: s.plugged, alertPct: state.lowPct, current: state.low);
    final t = s.tempC;
    final hot = s.healthOverheat ||
        (t != null && (t >= state.overheatC || (state.overheat && t > state.overheatC - 2))); // 2 C hysteresis
    final now = DateTime.now();
    // Chime on entry, then every 30 min while still unplugged and low (one chime path for the whole alert).
    if (sound && low && !state.night && (!state.low || now.difference(_lastChime ?? now).inMinutes >= 30)) {
      _lastChime = now;
      _store.playSound('low_battery');
    }
    if (sound && hot && !state.overheat) _store.playSound('overheat'); // not muted at night
    return state.copyWith(level: s.level, isCharging: s.charging, plugged: s.plugged, currentMa: s.currentMa, tempC: t, low: low, overheat: hot);
  }
}
