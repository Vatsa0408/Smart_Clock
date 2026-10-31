import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Roboto Flex style; [em] is letter-spacing in em, weight drives the wght axis.
TextStyle flex(double size, double weight, Color color,
        {double em = 0, double? height, bool tabular = false}) =>
    TextStyle(
      fontFamily: 'RobotoFlex',
      fontSize: size,
      fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
      fontVariations: [FontVariation('wght', weight)],
      color: color,
      letterSpacing: em * size,
      height: height,
      fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    );

/// 0 -> 1 -> 0 smooth wave (CSS ease-in-out alternate) over [period] seconds.
double wave(double s, double period, [double phase = 0]) =>
    0.5 - 0.5 * math.cos(2 * math.pi * (s / period + phase));

/// Rebuilds [builder] every frame with elapsed seconds; frozen at 0 when the
/// platform asks for reduced motion (CSS prefers-reduced-motion).
class Loop extends StatefulWidget {
  const Loop({super.key, required this.builder});
  final Widget Function(BuildContext context, double seconds) builder;

  @override
  State<Loop> createState() => _LoopState();
}

class _LoopState extends State<Loop> with SingleTickerProviderStateMixin {
  final _s = ValueNotifier<double>(0);
  late final Ticker _ticker = createTicker((d) => _s.value = d.inMicroseconds / 1e6);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _ticker.stop();
      _s.value = 0;
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _s.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<double>(valueListenable: _s, builder: (c, s, _) => widget.builder(c, s));
}

/// Entrance: fade + rise 28px + scale .97 -> 1 after [delay] (CSS "rise").
class Rise extends StatefulWidget {
  const Rise({super.key, required this.delay, required this.duration, required this.child});
  final Duration delay;
  final Duration duration;
  final Widget child;

  @override
  State<Rise> createState() => _RiseState();
}

class _RiseState extends State<Rise> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: widget.delay + widget.duration);
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Interval(
      widget.delay.inMicroseconds / (widget.delay + widget.duration).inMicroseconds,
      1,
      curve: const Cubic(.2, 0, 0, 1),
    ),
  );

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
        builder: (_, child) => Opacity(
          opacity: _t.value,
          child: Transform.translate(
            offset: Offset(0, 28 * (1 - _t.value)),
            child: Transform.scale(scale: .97 + .03 * _t.value, child: child),
          ),
        ),
      );
}

/// Blob outline shared by both weather icons (100x100 viewBox).
final Path blobPath = () {
  const pts = '94.20 50.00;93.40 52.84;91.25 55.43;88.43 57.64;85.77 59.58;83.98 61.53;83.37 63.82;83.78 66.66;84.64 70.00;85.20 73.52;84.81 76.71;83.17 79.09;80.38 80.38;76.91 80.69;73.37 80.46;70.28 80.36;67.90 81.00;66.15 82.74;64.69 85.47;63.12 88.65;61.12 91.51;58.61 93.27;55.73 93.50;52.77 92.24;50.00 90.00;47.54 87.59;45.29 85.81;43.00 85.19;40.42 85.77;37.41 87.10;34.08 88.44;30.76 89.01;27.90 88.28;25.84 86.16;24.67 83.01;24.17 79.46;23.82 76.18;23.02 73.66;21.34 71.99;18.68 70.93;15.36 70.00;12.03 68.72;9.46 66.79;8.22 64.18;8.49 61.12;9.96 57.96;11.94 55.01;13.57 52.39;14.20 50.00;13.57 47.61;11.94 44.99;9.96 42.04;8.49 38.88;8.22 35.82;9.46 33.21;12.03 31.28;15.36 30.00;18.68 29.07;21.34 28.01;23.02 26.34;23.82 23.82;24.17 20.54;24.67 16.99;25.84 13.84;27.90 11.72;30.76 10.99;34.08 11.56;37.41 12.90;40.42 14.23;43.00 14.81;45.29 14.19;47.54 12.41;50.00 10.00;52.77 7.76;55.73 6.50;58.61 6.73;61.12 8.49;63.12 11.35;64.69 14.53;66.15 17.26;67.90 19.00;70.28 19.64;73.37 19.54;76.91 19.31;80.38 19.62;83.17 20.91;84.81 23.29;85.20 26.48;84.64 30.00;83.78 33.34;83.37 36.18;83.98 38.47;85.77 40.42;88.43 42.36;91.25 44.57;93.40 47.16';
  final p = Path();
  var first = true;
  for (final pt in pts.split(';')) {
    final xy = pt.split(' ');
    final x = double.parse(xy[0]), y = double.parse(xy[1]);
    first ? p.moveTo(x, y) : p.lineTo(x, y);
    first = false;
  }
  return p..close();
}();
