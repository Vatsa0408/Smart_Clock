import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../../alarms/alarms_bloc.dart';
import '../../alarms/alarms_store.dart';
import '../../panel/panel_bloc.dart';
import '../../timers/timers_bloc.dart';
import '../clock_bloc.dart';

/// Next-alarm and running-timer chips; each opens its panel.
class GlanceChips extends StatelessWidget {
  const GlanceChips({super.key});

  @override
  Widget build(BuildContext context) {
    // Alarm and event text change at minute rate.
    final (now, hour24) = context.select((ClockBloc b) => (DateTime(b.state.now.year, b.state.now.month, b.state.now.day, b.state.now.hour, b.state.now.minute), b.state.hour24));
    final alarms = context.select((AlarmsBloc b) => b.state.alarms);
    final timer = context.select((TimersBloc b) => b.state.chip);
    void open(PanelKind k) => context.read<PanelBloc>().add(PanelOpened(k));

    final alarm = nextAlarmText(alarms, now, (h, m) => hm(h, m, hour24));

    return Row(
      children: [
        _Chip(Icons.notifications_none, kPrimary, alarm, 'Next alarm: $alarm. Open alarms', () => open(PanelKind.alarms)),
        if (timer != null) ...[
          const SizedBox(width: 12),
          _Chip(Icons.timer_outlined, const Color(0xFFCCC2DC), timer.done ? 'Done' : clockMs(timer.left), 'Open timers',
              () => open(PanelKind.timers)),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.icon, this.color, this.text, this.label, this.onTap);
  final IconData icon;
  final Color color;
  final String text, label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Btn(
        onTap: onTap,
        bg: const Color(0xFF3A2574),
        fg: const Color(0xFFEADDFF),
        size: 22,
        height: 52,
        radius: 26,
        padding: const EdgeInsets.fromLTRB(14, 0, 20, 0),
        alignment: Alignment.centerLeft,
        semantics: label,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: color),
            const SizedBox(width: 10),
            Flexible(
              child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
            ),
          ],
        ),
      );
}
