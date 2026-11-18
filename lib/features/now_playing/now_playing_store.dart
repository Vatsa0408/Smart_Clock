import 'dart:io';

import 'package:flutter/services.dart';

/// Android MediaSessionManager over channels; an empty stream elsewhere (Windows).
class NowPlayingStore {
  const NowPlayingStore();
  static const _events = EventChannel('smart_clock/now_playing/events');
  static const _ch = MethodChannel('smart_clock/now_playing');

  Stream<Map<Object?, Object?>> watch() => Platform.isAndroid
      ? _events.receiveBroadcastStream().map((e) => e as Map<Object?, Object?>)
      : const Stream.empty();

  Future<void> transport(String action) async {
    if (Platform.isAndroid) await _ch.invokeMethod<void>('transport', action);
  }

  Future<void> openAccessSettings() async {
    if (Platform.isAndroid) await _ch.invokeMethod<void>('openAccessSettings');
  }
}
