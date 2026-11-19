import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../timers_bloc.dart';

class TimersPanel extends StatelessWidget {
  const TimersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TimersBloc>();
    final sw = context.select((TimersBloc b) => b.state.stopwatchTab);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 420,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: kSurfaceLo, borderRadius: BorderRadius.circular(34)),
          child: Row(
            children: [
              for (final (label, isSw) in [('Timer', false), ('Stopwatch', true)])
                Expanded(
                  child: Btn(
                    onTap: () => bloc.add(TimersTabChanged(stopwatch: isSw)),
                    bg: segColors(sw == isSw).$1,
                    fg: segColors(sw == isSw).$2,
                    size: 22,
                    height: 52,
                    child: Text(label),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(child: sw ? const _Stopwatch() : const _Timers()),
      ],
    );
  }
}

class _Timers extends StatelessWidget {
  const _Timers();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TimersBloc>();
    final timers = context.select((TimersBloc b) => b.state.timers);
    final full = timers.length >= TimersState.maxTimers;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              mainAxisExtent: 112,
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              for (final m in [5, 10, 15, 30])
                Btn(
                  onTap: full ? null : () => bloc.add(TimerAdded(m)),
                  bg: kSecondary,
                  fg: kOnSecondary,
                  size: 38,
                  radius: 40,
                  child: Text('$m min'),
                ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 13,
          child: timers.isEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(8, 32, 8, 0),
                  child: Text('No timers running. Tap a preset to start one.', style: flex(26, 400, kMuted)),
                )
              : Column(
                  children: [
                    for (final t in timers)
                      Container(
                        height: 112,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.fromLTRB(20, 0, 24, 0),
                        decoration: BoxDecoration(
                          color: t.done ? const Color(0xFF633B48) : kSurfaceHi,
                          borderRadius: BorderRadius.circular(36),
                        ),
                        child: Row(
                          children: [
                            CustomPaint(
                              size: const Size.square(76),
                              painter: _RingPainter(1 - t.left / t.total, t.done ? const Color(0xFFEFB8C8) : kPrimary),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.done ? 'Done' : clockMs(t.left), style: flex(44, 600, Colors.white, height: 1, tabular: true)),
                                  const SizedBox(height: 6),
                                  Text(t.label, style: flex(18, 400, kMuted)),
                                ],
                              ),
                            ),
                            if (!t.done) ...[
                              Btn(
                                onTap: () => bloc.add(TimerToggled(t.id)),
                                bg: kPrimary,
                                fg: kOnPrimary,
                                height: 52,
                                padding: const EdgeInsets.symmetric(horizontal: 22),
                                child: Text(t.running ? 'Pause' : 'Resume'),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Btn(
                              onTap: () => bloc.add(TimerRemoved(t.id)),
                              bg: kSecondary,
                              fg: kOnSecondary,
                              height: 52,
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              child: Text(t.done ? 'Clear' : 'Stop'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// Progress ring: grey track and a [color] arc over [fraction] (0..1) of the circle, from 12 o'clock.
class _RingPainter extends CustomPainter {
  const _RingPainter(this.fraction, this.color);
  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: 30 * size.width / 76);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * math.pi, false, p..color = kSurface);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * fraction, false, p..color = color);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction || old.color != color;
}

class _Stopwatch extends StatelessWidget {
  const _Stopwatch();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TimersBloc>();
    final (running, sec) = context.select((TimersBloc b) => (b.state.swRunning, b.state.swSec));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(clockMs(sec), style: flex(190, 600, Colors.white, em: -.04, height: 1, tabular: true)),
        const SizedBox(width: 64),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Btn(
              onTap: () => bloc.add(const StopwatchToggled()),
              bg: running ? const Color(0xFFF2B8B5) : kPrimary,
              fg: running ? const Color(0xFF601410) : kOnPrimary,
              size: 30,
              width: 240,
              height: 88,
              child: Text(running ? 'Stop' : 'Start'),
            ),
            const SizedBox(height: 16),
            Btn(
              onTap: () => bloc.add(const StopwatchReset()),
              bg: kSecondary,
              fg: kOnSecondary,
              size: 24,
              width: 240,
              height: 72,
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}
