import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../controls_bloc.dart';
import '../controls_store.dart';

/// Scenes and device switches (placeholder data, see controls_store.dart).
class ControlsPanel extends StatelessWidget {
  const ControlsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ControlsBloc>();
    final s = context.watch<ControlsBloc>().state;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Scenes'),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final (i, sc) in Scene.values.indexed) ...[
                if (i > 0) const SizedBox(width: 14),
                Expanded(
                  child: Btn(
                    onTap: () => bloc.add(SceneSelected(sc)),
                    bg: s.scene == sc ? kPrimary : kSecondary,
                    fg: s.scene == sc ? kOnPrimary : kOnSecondary,
                    size: 26,
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(sceneInfo[sc]!.$2, size: 38), const SizedBox(width: 16), Text(sceneInfo[sc]!.$1)],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SectionLabel('Devices', top: 10),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final (i, d) in Device.values.indexed) ...[
                if (i > 0) const SizedBox(width: 14),
                Expanded(
                  child: Btn(
                    onTap: () => bloc.add(DeviceToggled(d)),
                    bg: s.on.contains(d) ? kPrimary : kSurfaceHi,
                    fg: s.on.contains(d) ? kOnPrimary : kText,
                    radius: 40,
                    height: 176,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
                    semantics: deviceInfo[d]!.$1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(deviceInfo[d]!.$2, size: 44),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(deviceInfo[d]!.$1, style: flex(25, 600, s.on.contains(d) ? kOnPrimary : kText, height: 1.1)),
                            const SizedBox(height: 6),
                            Text(s.on.contains(d) ? 'On' : 'Off', style: flex(19, 500, s.on.contains(d) ? kOnPrimary : kText)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
