import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../../panel/panel_bloc.dart';
import '../../settings/settings_bloc.dart';
import '../display_bloc.dart';

/// Night windows offered by the design (start hour, end hour).
const _windows = [(22, 6), (23, 7), (0, 8)];

class NightPanel extends StatelessWidget {
  const NightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsBloc>();
    final s = context.watch<SettingsBloc>().state;
    final manual = context.watch<DisplayBloc>().state.manual;

    Widget card(String title, String sub, {Widget? trailing, Widget? below}) => Container(
          constraints: const BoxConstraints(minHeight: 200),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 26),
          decoration: BoxDecoration(color: kSurfaceHi, borderRadius: BorderRadius.circular(40)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: flex(28, 600, Colors.white)),
                        const SizedBox(height: 6),
                        Text(sub, style: flex(19, 400, kMuted)),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[const SizedBox(width: 20), trailing],
                ],
              ),
              if (below != null) ...[const SizedBox(height: 14), below],
            ],
          ),
        );

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: card(
                'Night mode now',
                'Dim black screen with a big clock. Tap to exit.',
                trailing: Toggle(
                  on: manual,
                  label: 'Night mode now',
                  onTap: () {
                    context.read<DisplayBloc>().add(const DisplayNightManualSet(true));
                    context.read<PanelBloc>().add(const PanelClosed());
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: card(
                'Auto night mode',
                'Switches on by itself during these hours.',
                trailing: Toggle(
                  on: s.nightAuto,
                  label: 'Auto night mode',
                  onTap: () => settings.add(SettingsNightAutoToggled(!s.nightAuto)),
                ),
                below: Row(
                  children: [
                    for (final (i, (a, b)) in _windows.indexed) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: Btn(
                          onTap: () => settings.add(SettingsNightScheduleChanged(startMin: a * 60, endMin: b * 60)),
                          bg: segColors(s.nightStartMin == a * 60 && s.nightEndMin == b * 60).$1,
                          fg: segColors(s.nightStartMin == a * 60 && s.nightEndMin == b * 60).$2,
                          height: 52,
                          child: Text('${a.toString().padLeft(2, '0')}:00 – ${b.toString().padLeft(2, '0')}:00'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: card(
                'Dim with room light',
                "Lowers brightness when the room gets dark. Needs the tablet's light sensor.",
                trailing: Toggle(
                  on: s.ambient,
                  label: 'Dim with room light',
                  onTap: () => settings.add(SettingsAmbientToggled(!s.ambient)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: card(
                'Burn-in protection',
                'Slowly shifts the whole picture by a few pixels so nothing stays in one spot.',
                trailing: Toggle(
                  on: s.burnInOrbit,
                  label: 'Burn-in protection',
                  onTap: () => settings.add(SettingsBurnInToggled(!s.burnInOrbit)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
