import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../../weather/view/weather_row.dart';
import '../clock_bloc.dart';

const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _months = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December',
];

String _pad(int n) => n.toString().padLeft(2, '0');

(String hh, String mm, String ampm) _format(DateTime t, bool hour24) {
  if (hour24) return (_pad(t.hour), _pad(t.minute), '');
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return ('$h', _pad(t.minute), t.hour < 12 ? 'AM' : 'PM');
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, this.bg, this.fg);
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.only(left: 16, right: 22),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_outlined, size: 24, color: fg),
            const SizedBox(width: 10),
            Text(label, style: flex(20, 600, fg)),
          ],
        ),
      );
}

/// HH:MM with a blinking colon and an optional AM/PM suffix.
class _Time extends StatelessWidget {
  const _Time({
    required this.hh,
    required this.mm,
    required this.ampm,
    required this.size,
    required this.ampmSize,
    required this.ampmColor,
    required this.gap,
  });
  final String hh;
  final String mm;
  final String ampm;
  final double size;
  final double ampmSize;
  final Color ampmColor;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final style = flex(size, 640, Colors.white, em: -.045, height: .9, tabular: true);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(hh, style: style),
        Loop(
          builder: (_, s) => Opacity(
            opacity: 1 - .85 * wave(s, 2), // blink: 2s
            child: Transform.translate(
              offset: Offset(0, -.04 * size),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: .01 * size),
                child: Text(':', style: style),
              ),
            ),
          ),
        ),
        Text(mm, style: style),
        if (ampm.isNotEmpty) ...[
          SizedBox(width: gap),
          Text(ampm, style: flex(ampmSize, 600, ampmColor)),
        ],
      ],
    );
  }
}

class LocalCard extends StatelessWidget {
  const LocalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => context.read<ClockBloc>().add(const ClockFormatToggled()),
      child: _ClockCard(
        color: const Color(0xFF4F378B),
        blobs: const [Color(0xFF593FA0), Color(0xFF573E9C)],
        blobSizes: const [480, 440],
        blobPos: const [
          (left: null, right: -150, top: -190, bottom: null),
          (left: -170, right: null, top: null, bottom: -230),
        ],
        padding: const EdgeInsets.fromLTRB(44, 36, 44, 40),
        borderRadius: BorderRadius.circular(64),
        delay: Duration.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BlocSelector<ClockBloc, ClockState, DateTime>(
              selector: (s) => s.now,
              builder: (_, now) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _Pill('Current location', Color(0xFFD0BCFF), Color(0xFF381E72)),
                  Text(
                    '${_days[now.weekday - 1]} ${now.day} ${_months[now.month - 1]}',
                    style: flex(26, 500, const Color(0xFFEADDFF)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: BlocBuilder<ClockBloc, ClockState>(
                    buildWhen: (a, b) =>
                        a.now.minute != b.now.minute || a.now.hour != b.now.hour || a.hour24 != b.hour24,
                    builder: (_, s) {
                      final (hh, mm, ap) = _format(s.now, s.hour24);
                      return _Time(
                        hh: hh,
                        mm: mm,
                        ampm: ap,
                        size: 224,
                        ampmSize: 44,
                        ampmColor: const Color(0xFFD0BCFF),
                        gap: 18,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
                const _SecondsBar(),
              ],
            ),
            const WeatherRow(bangalore: false),
          ],
        ),
      ),
    );
  }
}

/// Fills to (second+1)/60 with a 1s linear glide; snaps back at second 0.
class _SecondsBar extends StatelessWidget {
  const _SecondsBar();

  @override
  Widget build(BuildContext context) => BlocSelector<ClockBloc, ClockState, int>(
        selector: (s) => s.now.second,
        builder: (_, sec) => Container(
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF6A4FA8),
            borderRadius: BorderRadius.circular(999),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: (sec + 1) / 60),
            duration: sec == 0 ? Duration.zero : const Duration(seconds: 1),
            builder: (_, f, _) => FractionallySizedBox(
              widthFactor: f,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFD0BCFF),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      );
}

class IndiaCard extends StatelessWidget {
  const IndiaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _ClockCard(
      color: const Color(0xFF633B48),
      blobs: const [Color(0xFF6A4150), Color(0xFF684050)],
      blobSizes: const [400, 360],
      blobPos: const [
        (left: null, right: -130, top: -170, bottom: null),
        (left: -150, right: null, top: null, bottom: -190),
      ],
      padding: const EdgeInsets.fromLTRB(44, 36, 40, 40),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(64),
        topRight: Radius.circular(64),
        bottomRight: Radius.circular(64),
        bottomLeft: Radius.circular(160),
      ),
      delay: const Duration(milliseconds: 120),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Pill('Bangalore · India', Color(0xFFEFB8C8), Color(0xFF492532)),
          BlocBuilder<ClockBloc, ClockState>(
            buildWhen: (a, b) =>
                a.india.minute != b.india.minute || a.india.hour != b.india.hour || a.hour24 != b.hour24,
            builder: (_, s) {
              final (hh, mm, ap) = _format(s.india, s.hour24);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Time(
                    hh: hh,
                    mm: mm,
                    ampm: ap,
                    size: 124,
                    ampmSize: 30,
                    ampmColor: const Color(0xFFEFB8C8),
                    gap: 12,
                  ),
                  const SizedBox(height: 14),
                  Text('IST · ${s.indiaOffset}', style: flex(22, 500, const Color(0xFFEFB8C8))),
                ],
              );
            },
          ),
          const WeatherRow(bangalore: true),
        ],
      ),
    );
  }
}

typedef _BlobPos = ({double? left, double? right, double? top, double? bottom});

/// Rounded card with two slowly counter-rotating background blobs.
class _ClockCard extends StatelessWidget {
  const _ClockCard({
    required this.color,
    required this.blobs,
    required this.blobSizes,
    required this.blobPos,
    required this.padding,
    required this.borderRadius,
    required this.delay,
    required this.child,
  });

  final Color color;
  final List<Color> blobs;
  final List<double> blobSizes;
  final List<_BlobPos> blobPos;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Duration delay;
  final Widget child;

  @override
  Widget build(BuildContext context) => Rise(
        delay: delay,
        duration: const Duration(milliseconds: 900),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: ColoredBox(
            color: color,
            child: Stack(
              fit: StackFit.expand,
              children: [
                for (final i in [0, 1])
                  Positioned(
                    left: blobPos[i].left,
                    right: blobPos[i].right,
                    top: blobPos[i].top,
                    bottom: blobPos[i].bottom,
                    width: blobSizes[i],
                    height: blobSizes[i],
                    child: Loop(
                      builder: (_, s) => Transform.rotate(
                        // 90s forward / 130s reverse
                        angle: (i == 0 ? 1 : -1) * 2 * math.pi * s / (i == 0 ? 90 : 130),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: blobs[i],
                            borderRadius: BorderRadius.circular(blobSizes[i] * .3),
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(padding: padding, child: child),
              ],
            ),
          ),
        ),
      );
}
