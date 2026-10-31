import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../../clock/clock_bloc.dart';
import '../sensor_bloc.dart';
import '../sensor_store.dart';

const _staleAfter = Duration(minutes: 30);

class SensorStrip extends StatelessWidget {
  const SensorStrip({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild once a minute (reuses the clock ticker) so stale readings expire.
    context.select((ClockBloc b) => b.state.now.minute);
    final rooms = context.select((SensorBloc b) => b.state.rooms);
    final now = DateTime.now();

    return Row(
      children: [
        for (final (i, r) in rooms.indexed) ...[
          if (i > 0) const SizedBox(width: 20),
          Expanded(
            child: Rise(
              key: ValueKey(r.name),
              delay: Duration(milliseconds: 600 + 100 * i),
              duration: const Duration(milliseconds: 800),
              child: _RoomCard(r, fresh: r.seenAt != null && now.difference(r.seenAt!) < _staleAfter),
            ),
          ),
        ],
      ],
    );
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
    final value = flex(34, 600, Colors.white, em: -.02, height: 1, tabular: true);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
        color: const Color(0xFF211F26),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(room.name, style: flex(18, 600, const Color(0xFFCAC4D0), height: 1), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            children: [
              Loop(
                builder: (_, s) => Transform.scale(
                  scale: 1 + .15 * wave(s, 3.2), // pulse: 3.2s
                  child: const _Badge(Icons.thermostat_rounded, Color(0xFFEFB8C8), Color(0xFF492532)),
                ),
              ),
              const SizedBox(width: 10),
              Text(t == null ? '--°C' : '${t.toStringAsFixed(1)}°C', style: value),
              const SizedBox(width: 22),
              Loop(
                builder: (_, s) => Transform.translate(
                  offset: Offset(0, -3 * wave(s, 3.6)), // bob: 3.6s
                  child: const _Badge(Icons.water_drop_outlined, Color(0xFFD0BCFF), Color(0xFF381E72)),
                ),
              ),
              const SizedBox(width: 10),
              Text(h == null ? '--%' : '${h.round()}%', style: value),
            ],
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
