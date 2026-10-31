import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../sensor_bloc.dart';
import '../sensor_store.dart';

class SensorStrip extends StatelessWidget {
  const SensorStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SensorBloc, SensorState, SensorReading?>(
      selector: (s) => s.reading,
      builder: (context, r) => Row(children: [
        const Expanded(
          child: _Tile(Icons.home_outlined, Color(0xFFCCC2DC), Color(0xFF332D41),
              child: _Title()),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _Tile(Icons.thermostat, const Color(0xFFEFB8C8), const Color(0xFF492532),
              child: _Value(r == null ? '--' : '${r.temperature}°C', 'Temperature')),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _Tile(Icons.water_drop_outlined, const Color(0xFFD0BCFF), const Color(0xFF381E72),
              child: _Value(r == null ? '--' : '${r.humidity}%', 'Humidity')),
        ),
      ]),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.icon, this.bg, this.fg, {required this.child});
  final IconData icon;
  final Color bg;
  final Color fg;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.only(left: 12, right: 28),
        decoration: BoxDecoration(
            color: const Color(0xFF211F26), borderRadius: BorderRadius.circular(36)),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 26, color: fg),
          ),
          const SizedBox(width: 16),
          child,
        ]),
      );
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Indoor',
              style: TextStyle(fontSize: 26, height: 1, fontWeight: FontWeight.w600, color: Color(0xFFE6E0E9))),
          SizedBox(height: 2),
          Text('Xiaomi sensor',
              style: TextStyle(fontSize: 17, height: 1, fontWeight: FontWeight.w500, color: Color(0xFFCAC4D0))),
        ],
      );
}

class _Value extends StatelessWidget {
  const _Value(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(value,
              style: const TextStyle(
                fontSize: 38,
                height: 1,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.76,
                fontFeatures: [FontFeature.tabularFigures()],
                color: Colors.white,
              )),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFFCAC4D0))),
        ],
      );
}
