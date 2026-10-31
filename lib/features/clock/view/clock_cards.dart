import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../weather/view/weather_row.dart';
import '../clock_bloc.dart';

const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _months = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December',
];

String _pad(int n) => n.toString().padLeft(2, '0');

(String time, String ampm) _format(DateTime t, bool hour24) {
  if (hour24) return ('${_pad(t.hour)}:${_pad(t.minute)}', '');
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return ('$h:${_pad(t.minute)}', t.hour < 12 ? 'AM' : 'PM');
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
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.location_on_outlined, size: 24, color: fg),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: fg)),
        ]),
      );
}

class _Time extends StatelessWidget {
  const _Time(this.time, this.ampm, this.timeSize, this.ampmSize, this.ampmColor);
  final String time;
  final String ampm;
  final double timeSize;
  final double ampmSize;
  final Color ampmColor;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(time,
              style: TextStyle(
                fontSize: timeSize,
                height: 0.9,
                fontWeight: FontWeight.w700,
                letterSpacing: -timeSize * 0.045,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: Colors.white,
              )),
          if (ampm.isNotEmpty) ...[
            SizedBox(width: timeSize > 200 ? 18 : 12),
            Text(ampm,
                style: TextStyle(
                    fontSize: ampmSize, fontWeight: FontWeight.w600, color: ampmColor)),
          ],
        ],
      );
}

class LocalCard extends StatelessWidget {
  const LocalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => context.read<ClockBloc>().add(const ClockFormatToggled()),
      child: Container(
        padding: const EdgeInsets.fromLTRB(44, 36, 44, 40),
        decoration: BoxDecoration(
            color: const Color(0xFF4F378B), borderRadius: BorderRadius.circular(64)),
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: Color(0xFFEADDFF)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocSelector<ClockBloc, ClockState, DateTime>(
                selector: (s) => s.now,
                builder: (_, now) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _Pill('Current location', Color(0xFFD0BCFF), Color(0xFF381E72)),
                    Text(
                      '${_days[now.weekday - 1]} ${now.day} ${_months[now.month - 1]}',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              BlocBuilder<ClockBloc, ClockState>(builder: (_, s) {
                final (t, ap) = _format(s.now, s.hour24);
                return _Time(t, ap, 236, 44, const Color(0xFFD0BCFF));
              }),
              const WeatherRow(
                bangalore: false,
                icon: Icons.wb_cloudy_outlined,
                badge: Color(0xFFD0BCFF),
                iconColor: Color(0xFF381E72),
                accent: Color(0xFFD0BCFF),
                size: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IndiaCard extends StatelessWidget {
  const IndiaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(44, 36, 40, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF633B48),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(64),
          topRight: Radius.circular(64),
          bottomRight: Radius.circular(64),
          bottomLeft: Radius.circular(160),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Color(0xFFFFD8E4)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Pill('Bangalore · India', Color(0xFFEFB8C8), Color(0xFF492532)),
            BlocBuilder<ClockBloc, ClockState>(builder: (_, s) {
              final (t, ap) = _format(s.india, s.hour24);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Time(t, ap, 124, 30, const Color(0xFFEFB8C8)),
                  const SizedBox(height: 14),
                  Text('IST · ${s.indiaOffset}',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFEFB8C8))),
                ],
              );
            }),
            const WeatherRow(
              bangalore: true,
              icon: Icons.grain,
              badge: Color(0xFFEFB8C8),
              iconColor: Color(0xFF492532),
              accent: Color(0xFFEFB8C8),
              size: 0.8,
            ),
          ],
        ),
      ),
    );
  }
}
