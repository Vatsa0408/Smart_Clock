import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../../timers/timers_bloc.dart';
import '../../todo/todo_bloc.dart';
import '../panel_bloc.dart';

const _tools = [
  (PanelKind.alarms, 'Alarms', Icons.notifications_none),
  (PanelKind.timers, 'Timers and stopwatch', Icons.timer_outlined),
  (PanelKind.controls, 'Quick controls', Icons.tune),
  (PanelKind.todo, 'To-do list', Icons.checklist),
  (PanelKind.night, 'Night mode', Icons.bedtime_outlined),
];

/// Round tool buttons that toggle the bottom-sheet panels.
class ToolsDock extends StatelessWidget {
  const ToolsDock({super.key});

  @override
  Widget build(BuildContext context) {
    final open = context.select((PanelBloc b) => b.state.panel);
    final timers = context.select((TimersBloc b) => b.state.timers.length);
    final todo = context.select((TodoBloc b) => b.state.open);
    return Rise(
      delay: const Duration(milliseconds: 600),
      duration: const Duration(milliseconds: 800),
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(color: kSurfaceLo, borderRadius: BorderRadius.circular(50)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, (kind, label, icon)) in _tools.indexed) ...[
              if (i > 0) const SizedBox(width: 10),
              _Tool(
                icon: icon,
                label: label,
                active: open == kind,
                badge: switch (kind) {
                  PanelKind.timers => timers,
                  PanelKind.todo => todo,
                  _ => 0,
                },
                onTap: () => context.read<PanelBloc>().add(PanelToggled(kind)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  const _Tool({required this.icon, required this.label, required this.active, required this.badge, required this.onTap});
  final IconData icon;
  final String label;
  final bool active;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 64,
        height: 64,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Btn(
                onTap: onTap,
                bg: active ? kPrimary : kSurfaceHi,
                fg: active ? kOnPrimary : kText,
                semantics: label,
                child: Icon(icon, size: 30),
              ),
            ),
            if (badge > 0)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 24),
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: const Color(0xFFF2B8B5), borderRadius: BorderRadius.circular(12)),
                  child: Text('$badge', style: flex(15, 700, const Color(0xFF601410))),
                ),
              ),
          ],
        ),
      );
}
