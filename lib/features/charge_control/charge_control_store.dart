import 'dart:io';

import 'package:flutter/services.dart';

/// Owns the `smart_clock/charge` channel (Android only; Windows returns null/false).
class ChargeControlStore {
  const ChargeControlStore();
  static const _ch = MethodChannel('smart_clock/charge');

  /// Samsung "Protect battery" as the system reports it; null off Android.
  Future<bool?> protectOn() async => Platform.isAndroid ? _ch.invokeMethod<bool>('protectState') : null;

  Future<bool> serviceEnabled() async =>
      Platform.isAndroid && (await _ch.invokeMethod<bool>('serviceEnabled') ?? false);

  /// Opens Samsung Settings; the accessibility service taps the switch (the tablet then reboots).
  Future<void> setProtect(bool on) async {
    if (Platform.isAndroid) await _ch.invokeMethod<void>('setProtect', {'on': on});
  }

  Future<void> openAccessibility() async {
    if (Platform.isAndroid) await _ch.invokeMethod<void>('openA11y');
  }
}
