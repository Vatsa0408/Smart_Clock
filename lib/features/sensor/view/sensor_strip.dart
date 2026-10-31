import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../clock/clock_bloc.dart';
import '../sensor_bloc.dart';
import '../sensor_store.dart';

/// Readings older than this are shown as "--".
const _staleAfter = Duration(minutes: 30);

class SensorStrip extends StatelessWidget {
  const SensorStrip({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild once a minute (reuses the clock ticker) so stale readings expire.
    context.select((ClockBloc b) => b.state.now.minute);
    final rooms = context.select((SensorBloc b) => b.state.rooms);
    final now = DateTime.now();
    return Row(children: [
      for (final (i, r) in rooms.indexed) ...[
        if (i > 0) const SizedBox(width: 20),
        Expanded(child: _RoomCard(r, fresh: r.seenAt != null && now.difference(r.seenAt!) < _staleAfter)),
      ],
    ]);
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard(this.room, {required this.fresh});
  final RoomSensor room;
  final bool fresh;

  @override
  Widget build(BuildContext context) {
    final t = fresh ? room.temperature : null;
    final h = fresh ? room.humidity : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
          color: const Color(0xFF211F26), borderRadius: BorderRadius.circular(40)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(room.name,
              style: const TextStyle(
                  fontSize: 18, height: 1, fontWeight: FontWeight.w600, color: Color(0xFFCAC4D0))),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(children: [
              const _Badge(Icons.thermostat, Color(0xFFEFB8C8), Color(0xFF492532)),
              const SizedBox(width: 10),
              _Value(t == null ? '--' : '${t.toStringAsFixed(1)}°C'),
              const SizedBox(width: 22),
              const _Badge(Icons.water_drop_outlined, Color(0xFFD0BCFF), Color(0xFF381E72)),
              const SizedBox(width: 10),
              _Value(h == null ? '--' : '${h.round()}%'),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.icon, this.bg, this.fg);
  final IconData icon;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: fg),
      );
}

class _Value extends StatelessWidget {
  const _Value(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
        fontSize: 34,
        height: 1,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.68,
        fontFeatures: [FontFeature.tabularFigures()],
        color: Colors.white,
      ));
}
