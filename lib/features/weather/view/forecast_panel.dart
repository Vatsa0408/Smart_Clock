import 'package:flutter/material.dart';

import '../../../shared/ui.dart';

/// Placeholder: the weather store only has current/high/low, so hourly, daily,
/// sun times and the alert line below are sample data from the design.
class _Place {
  const _Place(this.name, this.sunrise, this.sunset, this.accent, this.alertBg, this.alertFg, this.alert, this.hourly, this.daily);
  final String name, sunrise, sunset, alert;
  final Color accent, alertBg, alertFg;
  final List<(IconData, int)> hourly;
  final List<(IconData, int, int)> daily;
}

const _sun = Icons.wb_sunny_outlined, _cloud = Icons.cloud_outlined, _rain = Icons.umbrella_outlined;
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const _places = [
  _Place('Current location', '07:21', '16:09', kPrimary, Color(0xFF4F378B), Color(0xFFEADDFF), 'Rain expected after 18:00',
      [(_cloud, 14), (_cloud, 15), (_cloud, 13), (_rain, 12), (_rain, 11), (_cloud, 10)],
      [(_rain, 12, 8), (_cloud, 11, 6), (_sun, 13, 5)]),
  _Place('Bangalore', '06:10', '17:49', Color(0xFFEFB8C8), Color(0xFF633B48), Color(0xFFFFD8E4), 'Light rain through the evening',
      [(_rain, 27), (_rain, 26), (_cloud, 25), (_cloud, 23), (_cloud, 22), (_cloud, 21)],
      [(_rain, 28, 20), (_cloud, 29, 20), (_sun, 30, 21)]),
];

class ForecastPanel extends StatelessWidget {
  const ForecastPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Row(
      children: [
        for (final (pi, p) in _places.indexed) ...[
          if (pi > 0) const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              decoration: BoxDecoration(color: kSurfaceHi, borderRadius: BorderRadius.circular(40)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p.name, style: flex(26, 600, Colors.white)),
                      Flexible(
                        child: Text('Sunrise ${p.sunrise} · Sunset ${p.sunset}',
                            style: flex(19, 400, kMuted), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (final (i, h) in p.hourly.indexed) ...[
                        if (i > 0) const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(26)),
                            child: Column(
                              children: [
                                Text('${((now.hour + i * 3) % 24).toString().padLeft(2, '0')}:00', style: flex(17, 500, kMuted)),
                                const SizedBox(height: 8),
                                Icon(h.$1, size: 34, color: p.accent),
                                const SizedBox(height: 8),
                                Text('${h.$2}°', style: flex(25, 600, Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  for (final (i, d) in p.daily.indexed)
                    SizedBox(
                      height: 58,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 140,
                              child: Text(i == 0 ? 'Tomorrow' : _weekdays[(now.weekday + i) % 7], style: flex(23, 600, kText)),
                            ),
                            const SizedBox(width: 16),
                            Icon(d.$1, size: 30, color: p.accent),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: '${d.$2}° ',
                                  children: [TextSpan(text: '/ ${d.$3}°', style: flex(23, 500, kMuted))],
                                ),
                                textAlign: TextAlign.right,
                                style: flex(23, 600, Colors.white, tabular: true),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Spacer(),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(color: p.alertBg, borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        Icon(Icons.umbrella_outlined, size: 24, color: p.alertFg),
                        const SizedBox(width: 12),
                        Text(p.alert, style: flex(20, 600, p.alertFg)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
