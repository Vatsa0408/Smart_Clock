import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../../alarms/alarms_bloc.dart';
import '../../alarms/alarms_store.dart';
import '../../clock/clock_bloc.dart';
import '../../sensor/sensor_bloc.dart';
import '../display_bloc.dart';

const _fg = Color(0xFF8F8A9C);
const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _months = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December',
];

/// Black night screen: big clock, then "date · next alarm · temperature". Tap to exit.
class NightOverlay extends StatelessWidget {
  const NightOverlay({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<DisplayBloc, DisplayState>(
        buildWhen: (a, b) => a.night != b.night || a.shift != b.shift,
        builder: (context, d) {
          if (!d.night) return const SizedBox.shrink();
          return Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.read<DisplayBloc>().add(const DisplayNightExited()),
              child: Semantics(
                label: 'Exit night mode',
                button: true,
                child: ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: Transform.translate(
                      offset: orbitOffsets[d.shift] * 2,
                      child: const _NightClock(),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
}

class _NightClock extends StatelessWidget {
  const _NightClock();

  @override
  Widget build(BuildContext context) {
    final now = context.select((ClockBloc b) => b.state.now);
    final hour24 = context.select((ClockBloc b) => b.state.hour24);
    final alarms = context.select((AlarmsBloc b) => b.state.alarms);
    final temp = context.select(
      (SensorBloc b) => b.state.rooms.where((r) => r.temperature != null).firstOrNull?.temperature,
    );
    final h = hour24 ? now.hour.toString().padLeft(2, '0') : '${now.hour % 12 == 0 ? 12 : now.hour % 12}';
    final text = [
      '${_days[now.weekday - 1]} ${now.day} ${_months[now.month - 1]}',
      nextAlarmText(alarms, now, (h, m) => hm(h, m, hour24)),
      if (temp != null) '${temp.toStringAsFixed(1)}°C',
    ].join(' · ');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$h:${now.minute.toString().padLeft(2, '0')}', style: flex(330, 600, _fg, em: -.045, height: .9, tabular: true)),
        const SizedBox(height: 28),
        Text(text, style: flex(32, 500, _fg)),
      ],
    );
  }
}
