import 'dart:io';

import 'package:flutter/services.dart';

class DisplayStore {
  const DisplayStore();
  static const _ch = MethodChannel('smart_clock/display');

  /// null = follow system brightness. Android only; no-op elsewhere.
  Future<void> setBrightness(double? v) async {
    if (!Platform.isAndroid) return;
    await _ch.invokeMethod<void>('setBrightness', v ?? -1.0);
  }
}
