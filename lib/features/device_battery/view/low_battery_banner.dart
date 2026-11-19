import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../device_battery_bloc.dart';

/// Full-width "plug in" banner while the low-battery alert is active.
class LowBatteryBanner extends StatelessWidget {
  const LowBatteryBanner({super.key});

  @override
  Widget build(BuildContext context) => BlocSelector<DeviceBatteryBloc, DeviceBatteryState, bool>(
        selector: (s) => s.low,
        builder: (_, low) => low
            ? Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    color: const Color(0xFFB3261E),
                    child: Text('Battery low: plug in the charger', style: flex(26, 600, Colors.white)),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      );
}
