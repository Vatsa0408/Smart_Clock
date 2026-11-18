import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';

/// Platform escape hatches (Android only).
class SettingsStore {
  const SettingsStore();

  /// Escape hatch while this app is the HOME launcher: opens the default-home picker.
  Future<void> openHomeSettings() => _intent('android.settings.HOME_SETTINGS');
  Future<void> openAndroidSettings() => _intent('android.settings.SETTINGS');

  Future<void> _intent(String action) async {
    if (!Platform.isAndroid) return;
    await AndroidIntent(
          action: action,
          flags: const [0x10000000],
        ) // FLAG_ACTIVITY_NEW_TASK
        .launch()
        .catchError((_) {});
  }
}
