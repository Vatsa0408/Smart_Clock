import 'package:flutter/material.dart';

import '../../../shared/ui.dart';
import 'settings_page.dart';

/// Visible "App settings" pill (gear + label) that opens the Settings screen.
class SettingsEntry extends StatelessWidget {
  const SettingsEntry({super.key});

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFF2B2930),
    shape: const StadiumBorder(),
    child: InkWell(
      customBorder: const StadiumBorder(),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.settings_outlined, size: 22, color: Color(0xFFD0BCFF)),
            const SizedBox(width: 10),
            Text('App settings', style: flex(18, 500, const Color(0xFFE6E0E9))),
          ],
        ),
      ),
    ),
  );
}
