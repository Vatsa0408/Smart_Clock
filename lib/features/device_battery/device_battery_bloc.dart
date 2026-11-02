import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'device_battery_event.dart';
import 'device_battery_state.dart';

class DeviceBatteryBloc extends Bloc<DeviceBatteryEvent, DeviceBatteryState> {
  DeviceBatteryBloc() : super(const DeviceBatteryState()) {
    on<DeviceBatteryRequested>(_onRequested);
    on<DeviceBatteryUpdated>(_onUpdated);
  }

  static const _channel = MethodChannel('smart_clock/battery');
  bool _lowBatteryWarningTriggered = false;

  Future<void> _onRequested(
    DeviceBatteryRequested event,
    Emitter<DeviceBatteryState> emit,
  ) async {
    try {
      // Get initial battery level
      final level = await _channel.invokeMethod<int>('getBatteryLevel');
      final isCharging = await _channel.invokeMethod<bool?>('isCharging') ?? false;
      emit(DeviceBatteryState(level: level, isCharging: isCharging));

      // Initialize low battery warning state
      _lowBatteryWarningTriggered = level != null && level <= 20 && !isCharging;

      // Listen for battery changes
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onBatteryChanged') {
          final args = call.arguments as Map<dynamic, dynamic>;
          add(DeviceBatteryUpdated(
            level: args['level'] as int,
            isCharging: args['isCharging'] as bool? ?? false,
          ));
        }
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to get battery level: ${e.message}');
      // Default to unknown
      emit(const DeviceBatteryState(level: null, isCharging: false));
    }
  }

  void _onUpdated(
    DeviceBatteryUpdated event,
    Emitter<DeviceBatteryState> emit,
  ) {
    final level = event.level;
    final isCharging = event.isCharging;

    // Check if we should trigger low battery warning
    // Trigger when battery drops to 20% or below AND not charging
    // Reset warning when battery goes above 20% OR starts charging
    final shouldTriggerWarning = level <= 20 && !isCharging;
    final shouldResetWarning = level > 20 || isCharging;

    if (shouldResetWarning) {
      _lowBatteryWarningTriggered = false;
    }

    if (shouldTriggerWarning && !_lowBatteryWarningTriggered) {
      _lowBatteryWarningTriggered = true;
      _playLowBatterySound();
    }

    emit(DeviceBatteryState(level: level, isCharging: isCharging));
  }

  Future<void> _playLowBatterySound() async {
    try {
      await _channel.invokeMethod('playLowBatterySound');
    } on PlatformException catch (e) {
      debugPrint('Failed to play low battery sound: ${e.message}');
    }
  }
}