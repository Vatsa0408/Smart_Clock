import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../weather_bloc.dart';
import '../weather_store.dart';

/// Temp + condition + H/L row; [bangalore] picks which reading to show.
class WeatherRow extends StatelessWidget {
  const WeatherRow({
    super.key,
    required this.bangalore,
    required this.icon,
    required this.badge,
    required this.iconColor,
    required this.accent,
    required this.size,
  });

  final bool bangalore;
  final IconData icon;
  final Color badge;
  final Color iconColor;
  final Color accent;

  /// 1 for the large (local) variant, <1 for the compact one.
  final double size;

  @override
  Widget build(BuildContext context) {
    final big = size == 1;
    return BlocSelector<WeatherBloc, WeatherState, Weather?>(
      selector: (s) => bangalore ? s.bangalore : s.local,
      builder: (context, w) {
        if (w == null) return const SizedBox.shrink();
        return Row(
          children: [
            Container(
              width: big ? 112 : 88,
              height: big ? 112 : 88,
              decoration: BoxDecoration(color: badge, shape: BoxShape.circle),
              child: Icon(icon, size: big ? 64 : 50, color: iconColor),
            ),
            SizedBox(width: big ? 28 : 22),
            Text('${w.temp}°',
                style: TextStyle(
                  fontSize: big ? 88 : 72,
                  height: 1,
                  fontWeight: FontWeight.w600,
                  letterSpacing: big ? -2.6 : -2.2,
                  color: Colors.white,
                )),
            SizedBox(width: big ? 28 : 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(w.condition,
                    style: TextStyle(
                        fontSize: big ? 30 : 24, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('H ${w.high}° · L ${w.low}°',
                    style: TextStyle(
                        fontSize: big ? 22 : 20,
                        fontWeight: FontWeight.w500,
                        color: accent)),
              ],
            ),
          ],
        );
      },
    );
  }
}
