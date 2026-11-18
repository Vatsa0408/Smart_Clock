import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

typedef BatterySample = ({int? level, bool charging, double? tempC, bool healthOverheat});

/// Owns the `smart_clock/battery` channel (Android only).
class DeviceBatteryStore {
  DeviceBatteryStore() {
    if (Platform.isAndroid) _ch.setMethodCallHandler(_onCall); // once, not per request
  }

  static const _ch = MethodChannel('smart_clock/battery');
  final _updates = StreamController<BatterySample>.broadcast();
  Stream<BatterySample> get updates => _updates.stream;

  /// null where there is no tablet battery (Windows).
  Future<BatterySample?> read() async => Platform.isAndroid
      ? _parse(await _ch.invokeMapMethod<String, Object?>('getBattery') ?? const {})
      : null;

  Future<void> playSound(String type) async {
    if (Platform.isAndroid) await _ch.invokeMethod<void>('playSound', type);
  }

  Future<void> _onCall(MethodCall c) async {
    if (c.method == 'onBatteryChanged') _updates.add(_parse((c.arguments as Map).cast()));
  }

  static BatterySample _parse(Map<String, Object?> a) => (
        level: (a['level'] as num?)?.toInt(),
        charging: a['isCharging'] as bool? ?? false,
        tempC: (a['tempC'] as num?)?.toDouble(),
        healthOverheat: a['overheat'] as bool? ?? false,
      );
}
