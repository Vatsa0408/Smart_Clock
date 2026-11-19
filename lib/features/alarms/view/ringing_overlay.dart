import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../../clock/clock_bloc.dart';
import '../alarms_bloc.dart';
import '../alarms_store.dart';

/// Full-screen "alarm ringing" overlay: snooze, or dismiss (tap or 3 s hold).
class RingingOverlay extends StatelessWidget {
  const RingingOverlay({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AlarmsBloc, AlarmsState>(
        buildWhen: (a, b) => a.ringing != b.ringing || a.preview != b.preview,
        builder: (context, s) {
          final r = s.ringing;
          if (r == null) return const SizedBox.shrink();
          final hour24 = context.read<ClockBloc>().state.hour24;
          final hh = hour24 ? r.h.toString().padLeft(2, '0') : '${r.h % 12 == 0 ? 12 : r.h % 12}';
          final big = flex(220, 640, Colors.white, em: -.045, height: .9, tabular: true);
          return Positioned.fill(
            child: Semantics(
              label: 'Alarm ringing',
              child: ColoredBox(
                color: const Color(0xFF4F378B),
                child: ClipRect(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(right: -180, top: -220, width: 620, height: 620, child: _Blob(const Color(0xFF593FA0), 90, 1)),
                      Positioned(left: -200, bottom: -260, width: 560, height: 560, child: _Blob(const Color(0xFF573E9C), 120, -1)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _Bell(),
                          const SizedBox(height: 28),
                          Text('$hh:${r.m.toString().padLeft(2, '0')}', style: big),
                          const SizedBox(height: 28),
                          Text(s.preview ? '${r.label} (preview)' : r.label, style: flex(44, 600, const Color(0xFFEADDFF))),
                          const SizedBox(height: 28),
                          Text(
                            r.actions.isEmpty ? alarmSounds[r.sound] : r.actions.map(_ing).join(' · '),
                            style: flex(24, 500, kPrimary),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Btn(
                                onTap: () => context.read<AlarmsBloc>().add(AlarmSnoozed(DateTime.now())),
                                bg: kSecondary,
                                fg: kOnSecondary,
                                size: 30,
                                width: 340,
                                height: 96,
                                child: Text('Snooze ${r.snooze} min'),
                              ),
                              const SizedBox(width: 20),
                              _Dismiss(hold: r.hold, onDone: () => context.read<AlarmsBloc>().add(const AlarmDismissed())),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

  static String _ing(String a) => switch (a) {
        'Lights fade on' => 'Lights fading on',
        'Blinds open' => 'Blinds opening',
        _ => 'AC switched off',
      };
}

class _Blob extends StatelessWidget {
  const _Blob(this.color, this.period, this.dir);
  final Color color;
  final double period;
  final int dir;

  @override
  Widget build(BuildContext context) => Loop(
        builder: (_, s) => Transform.rotate(
          angle: dir * 2 * math.pi * s / period,
          child: DecoratedBox(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(620 * .3))),
        ),
      );
}

/// Pulsing ring around a wiggling bell.
class _Bell extends StatelessWidget {
  const _Bell();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 120,
        height: 120,
        child: Loop(
          builder: (_, s) {
            final p = (s % 2) / 2; // ringpulse 2s: scale .9 -> 1.5, opacity .5 -> 0
            // wiggle 1.6s: swings in the first 60%, rests for the rest.
            final w = (s % 1.6) / 1.6;
            final angle = w < .6 ? math.sin(w / .6 * 2 * math.pi * 2.5) * .28 * (1 - w / .6) : 0.0;
            return Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: .9 + .6 * p,
                  child: Opacity(
                    opacity: .5 * (1 - p),
                    child: const DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: kPrimary), child: SizedBox.expand()),
                  ),
                ),
                const DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: kPrimary), child: SizedBox.expand()),
                Transform.rotate(
                  angle: angle,
                  alignment: const Alignment(0, -.8),
                  child: const Icon(Icons.notifications_none, size: 64, color: kOnPrimary),
                ),
              ],
            );
          },
        ),
      );
}

/// 400x96 dismiss button; [hold] fills a progress bar over 3 s before it dismisses.
class _Dismiss extends StatefulWidget {
  const _Dismiss({required this.hold, required this.onDone});
  final bool hold;
  final VoidCallback onDone;

  @override
  State<_Dismiss> createState() => _DismissState();
}

class _DismissState extends State<_Dismiss> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    });

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _release() {
    if (_c.status != AnimationStatus.completed) _c.animateBack(0, duration: const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (_) => widget.hold ? _c.forward() : widget.onDone(),
        onPointerUp: (_) => _release(),
        onPointerCancel: (_) => _release(),
        child: Container(
          width: 400,
          height: 96,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(999)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (_, _) => Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(widthFactor: _c.value, child: const ColoredBox(color: Color(0xFF9A82DB), child: SizedBox.expand())),
                  ),
                ),
              ),
              Text(widget.hold ? 'Hold to dismiss' : 'Dismiss', style: flex(30, 600, kOnPrimary)),
            ],
          ),
        ),
      );
}
