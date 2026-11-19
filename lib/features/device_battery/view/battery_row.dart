import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../../sensor/sensor_bloc.dart';
import '../device_battery_bloc.dart';

const _hot = Color(0xFFF44336);

/// Tablet battery (and overheat badge) and averaged sensor battery.
class BatteryRow extends StatelessWidget {
  const BatteryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<DeviceBatteryBloc, DeviceBatteryState>(
          builder: (_, state) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.overheat) ...[
                const Icon(Icons.thermostat, color: _hot, size: 22),
                Text('${state.tempC?.round() ?? '!'}°C', style: flex(20, 600, _hot)),
                const SizedBox(width: 16),
              ],
              if (state.level != null)
                BatteryIndicator(percentage: state.level!, isCharging: state.isCharging),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Sensor battery (average of all sensors)
        BlocBuilder<SensorBloc, SensorState>(
          buildWhen: (a, b) {
            if (a.rooms.length != b.rooms.length) return true;
            for (var i = 0; i < a.rooms.length; i++) {
              if (a.rooms[i].battery != b.rooms[i].battery) return true;
            }
            return false;
          },
          builder: (_, state) {
            final batteries = state.rooms
                .where((r) => r.configured && r.battery != null)
                .map((r) => r.battery!)
                .toList();
            if (batteries.isEmpty) return const SizedBox.shrink();
            final avgBattery =
                (batteries.reduce((a, b) => a + b) / batteries.length).round();
            return BatteryIndicator(percentage: avgBattery);
          },
        ),
      ],
    );
  }
}

