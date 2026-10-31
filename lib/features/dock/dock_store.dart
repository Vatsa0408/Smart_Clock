import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:url_launcher/url_launcher.dart';

final class DockApp {
  const DockApp(this.label, this.package);
  final String label;
  final String package;
}

class DockStore {
  const DockStore();

  static const apps = [
    DockApp('YouTube Music', 'com.google.android.apps.youtube.music'),
    DockApp('Spotify', 'com.spotify.music'),
    DockApp('Google Home', 'com.google.android.apps.chromecast.app'),
  ];

  static const _webUrls = {
    'com.google.android.apps.youtube.music': 'https://music.youtube.com',
    'com.spotify.music': 'https://open.spotify.com',
    'com.google.android.apps.chromecast.app': 'https://home.google.com',
  };

  bool get supported => Platform.isAndroid || Platform.isWindows;

  /// Android: launch the app by package. Windows: open the web equivalent.
  /// Errors (app not installed, no browser) are swallowed.
  Future<void> launch(DockApp app) async {
    try {
      if (Platform.isAndroid) {
        await AndroidIntent(
          action: 'android.intent.action.MAIN',
          category: 'android.intent.category.LAUNCHER',
          package: app.package,
          flags: const [0x10000000], // FLAG_ACTIVITY_NEW_TASK
        ).launch();
      } else if (Platform.isWindows) {
        await launchUrl(Uri.parse(_webUrls[app.package]!));
      }
    } catch (_) {
      // Android: app not installed -> open the web version instead.
      if (Platform.isAndroid) {
        await launchUrl(Uri.parse(_webUrls[app.package]!))
            .catchError((_) => false);
      }
    }
  }
}
