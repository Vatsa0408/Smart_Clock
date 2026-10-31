import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../weather_bloc.dart';
import '../weather_store.dart';

/// Icon + temp + condition + H/L row; [bangalore] picks the reading and palette.
class WeatherRow extends StatelessWidget {
  const WeatherRow({super.key, required this.bangalore});

  final bool bangalore;

  @override
  Widget build(BuildContext context) {
    final big = !bangalore;
    final accent = bangalore ? const Color(0xFFEFB8C8) : const Color(0xFFD0BCFF);
    final fg = bangalore ? const Color(0xFF492532) : const Color(0xFF381E72);
    final text = bangalore ? const Color(0xFFFFD8E4) : const Color(0xFFEADDFF);
    return BlocSelector<WeatherBloc, WeatherState, Weather?>(
      selector: (s) => bangalore ? s.bangalore : s.local,
      builder: (context, w) {
        if (w == null) return const SizedBox.shrink();
        return Row(
          children: [
            _WeatherIcon(rain: bangalore, size: big ? 112 : 88, badge: accent, fg: fg),
            SizedBox(width: big ? 28 : 22),
            Text('${w.temp}°', style: flex(big ? 88 : 72, 600, Colors.white, em: -.03, height: 1)),
            SizedBox(width: big ? 28 : 22),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(w.condition, style: flex(big ? 30 : 24, 600, text), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('H ${w.high}° · L ${w.low}°', style: flex(big ? 22 : 20, 500, accent)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Spinning blob badge with a bobbing sun/cloud (or rain cloud) glyph.
class _WeatherIcon extends StatelessWidget {
  const _WeatherIcon({required this.rain, required this.size, required this.badge, required this.fg});
  final bool rain;
  final double size;
  final Color badge;
  final Color fg;

  @override
  Widget build(BuildContext context) => Loop(
        builder: (_, s) => Transform.translate(
          offset: Offset(0, -6 * wave(s, 5)), // bob: 5s
          child: CustomPaint(size: Size.square(size), painter: _IconPainter(rain, badge, fg, s)),
        ),
      );
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.rain, this.badge, this.fg, this.s);
  final bool rain;
  final Color badge;
  final Color fg;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    // Blob spins around its bounding-box centre, 36s per turn.
    canvas.save();
    canvas.translate(51.21, 50);
    canvas.rotate(2 * math.pi * s / 36);
    canvas.translate(-51.21, -50);
    canvas.drawPath(blobPath, Paint()..color = badge);
    canvas.restore();

    canvas.translate(26, 26);
    canvas.scale(2);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = fg;
    final fill = Paint()..color = badge;

    if (rain) {
      final cloud = Path()
        ..moveTo(7.5, 14)
        ..lineTo(16.5, 14)
        ..arcToPoint(const Offset(17, 6.43), radius: const Radius.circular(3.8), clockwise: false)
        ..arcToPoint(const Offset(6.4, 7.6), radius: const Radius.circular(5.5), clockwise: false)
        ..arcToPoint(const Offset(7.5, 14), radius: const Radius.circular(3.2), clockwise: false)
        ..close();
      canvas.drawPath(cloud, fill);
      canvas.drawPath(cloud, stroke);
      // rain: 1.4s ease-in; fade in to 30%, out by 100%, drifting down-left.
      final p = (s % 1.4) / 1.4;
      final a = p < .3 ? p / .3 : 1 - (p - .3) / .7;
      final e = Curves.easeIn.transform(p);
      canvas.save();
      canvas.translate(.8 - 1.6 * e, -1.5 + 3.5 * e);
      final drops = Path();
      for (final x in [9.0, 13.0, 17.0]) {
        drops
          ..moveTo(x, 17.5)
          ..relativeLineTo(-1, 2);
      }
      canvas.drawPath(drops, stroke..color = fg.withValues(alpha: a.clamp(0, 1)));
      canvas.restore();
    } else {
      canvas.drawCircle(const Offset(9, 9), 3, stroke);
      final rays = Path()
        ..moveTo(9, 3)..relativeLineTo(0, 1.2)
        ..moveTo(3, 9)..relativeLineTo(1.2, 0)
        ..moveTo(4.8, 4.8)..relativeLineTo(.9, .9)
        ..moveTo(13.2, 4.8)..relativeLineTo(-.9, .9);
      canvas.drawPath(rays, stroke..color = fg.withValues(alpha: .3 + .7 * (1 - wave(s, 2.4))));
      stroke.color = fg;
      final cloud = Path()
        ..moveTo(8.5, 20)
        ..lineTo(17, 20)
        ..arcToPoint(const Offset(17.4, 13.03), radius: const Radius.circular(3.5), clockwise: false)
        ..arcToPoint(const Offset(8, 14.2), radius: const Radius.circular(5), clockwise: false)
        ..arcToPoint(const Offset(8.5, 20), radius: const Radius.circular(3), clockwise: false)
        ..close();
      canvas.drawPath(cloud, fill);
      canvas.drawPath(cloud, stroke);
    }
  }

  @override
  bool shouldRepaint(_IconPainter old) => old.s != s || old.rain != rain || old.badge != badge;
}
