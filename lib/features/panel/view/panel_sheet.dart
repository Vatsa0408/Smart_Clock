import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../../alarms/alarms_bloc.dart';
import '../../alarms/view/alarms_panel.dart';
import '../../calendar/view/calendar_panel.dart';
import '../../controls/view/controls_panel.dart';
import '../../display/view/night_panel.dart';
import '../../timers/view/timers_panel.dart';
import '../../todo/view/todo_panel.dart';
import '../../weather/view/forecast_panel.dart';
import '../panel_bloc.dart';

const _titles = {
  PanelKind.alarms: 'Alarms',
  PanelKind.timers: 'Timers',
  PanelKind.controls: 'Quick controls',
  PanelKind.todo: 'To-do',
  PanelKind.night: 'Night mode',
  PanelKind.forecast: 'Forecast',
  PanelKind.calendar: 'Calendar',
};

/// Scrim + 616 px bottom sheet; empty when no panel is open.
class PanelSheet extends StatelessWidget {
  const PanelSheet({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<PanelBloc, PanelState>(
        builder: (context, s) {
          final kind = s.panel;
          if (kind == null) return const SizedBox.shrink();
          void close() => context.read<PanelBloc>().add(const PanelClosed());
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: close,
                  child: const ColoredBox(color: Color(0x9E0A080E)),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 616,
                child: _SlideUp(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(40, 24, 40, 28),
                    decoration: const BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 64,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              kind == PanelKind.alarms
                                  ? const AlarmsTitle()
                                  : Text(_titles[kind]!, style: flex(36, 600, Colors.white, em: -.01)),
                              Row(
                                children: [
                                  if (kind == PanelKind.alarms) const AlarmsActions(),
                                  const SizedBox(width: 12),
                                  Btn(
                                    onTap: () => kind == PanelKind.alarms && context.read<AlarmsBloc>().state.editing != null
                                        ? context.read<AlarmsBloc>().add(const AlarmEditCancelled())
                                        : close(),
                                    bg: kSecondary,
                                    fg: kOnSecondary,
                                    width: 56,
                                    height: 56,
                                    semantics: 'Close',
                                    child: const Icon(Icons.close, size: 26),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: switch (kind) {
                            PanelKind.alarms => const AlarmsPanel(),
                            PanelKind.timers => const TimersPanel(),
                            PanelKind.controls => const ControlsPanel(),
                            PanelKind.todo => const TodoPanel(),
                            PanelKind.night => const NightPanel(),
                            PanelKind.forecast => const ForecastPanel(),
                            PanelKind.calendar => const CalendarPanel(),
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
}

/// Slides the sheet up from the bottom edge (450 ms); instant under reduced motion.
class _SlideUp extends StatefulWidget {
  const _SlideUp({required this.child});
  final Widget child;

  @override
  State<_SlideUp> createState() => _SlideUpState();
}

class _SlideUpState extends State<_SlideUp> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
  late final _t = CurvedAnimation(parent: _c, curve: const Cubic(.2, 0, 0, 1));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _t,
        child: widget.child,
        builder: (_, child) => Transform.translate(offset: Offset(0, 616 * (1 - _t.value)), child: child),
      );
}
