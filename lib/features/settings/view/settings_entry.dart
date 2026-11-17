import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'settings_page.dart';

/// Hidden entry: an invisible 200x56 hit area; a 2 s long-press opens Settings.
/// Overlay it in a Stack so it does not depend on (or take space from) the battery row.
class SettingsEntry extends StatelessWidget {
  const SettingsEntry({super.key});

  @override
  Widget build(BuildContext context) => RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: {
          LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
            () => LongPressGestureRecognizer(duration: const Duration(seconds: 2)),
            (r) => r.onLongPress = () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => const SettingsPage())),
          ),
        },
        child: const SizedBox(width: 200, height: 56),
      );
}
