import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'features/clock/clock_bloc.dart';
import 'features/clock/view/clock_cards.dart';
import 'features/device_battery/device_battery_bloc.dart';
import 'features/device_battery/device_battery_store.dart';
import 'features/diagnostics/diagnostics_bloc.dart';
import 'features/diagnostics/diagnostics_store.dart';
import 'features/display/display_bloc.dart';
import 'features/display/display_store.dart';
import 'features/dock/dock_bloc.dart';
import 'features/dock/dock_store.dart';
import 'features/dock/view/dock_bar.dart';
import 'features/sensor/sensor_bloc.dart';
import 'features/settings/settings_bloc.dart';
import 'features/settings/settings_store.dart';
import 'features/settings/view/settings_entry.dart';
import 'features/sensor/sensor_store.dart';
import 'features/sensor/view/sensor_strip.dart';
import 'features/weather/weather_bloc.dart';
import 'features/weather/weather_store.dart';
import 'shared/ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final support = await getApplicationSupportDirectory();
  final log = DiagnosticsStore(support);
  log.write(
    'I',
    'app start',
  ); // counting these in the soak shows silent restarts
  FlutterError.onError = (d) {
    if (kDebugMode) FlutterError.presentError(d);
    log.write('E', d.exceptionAsString(), d.stack);
  };
  WidgetsBinding.instance.platformDispatcher.onError = (e, s) {
    log.write('E', e, s);
    return true;
  };
  final printer = debugPrint;
  debugPrint = (m, {wrapWidth}) {
    printer(m, wrapWidth: wrapWidth);
    if (m != null) log.write('D', m);
  };
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(support.path),
  );
  runApp(SmartClockApp(log: log));
}

class SmartClockApp extends StatelessWidget {
  const SmartClockApp({super.key, required this.log});

  final DiagnosticsStore log;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SettingsBloc(const SettingsStore()),
        ), // first: others seed from it
        BlocProvider(create: (_) => DiagnosticsBloc(log)),
        BlocProvider(create: (_) => ClockBloc()),
        BlocProvider(
          create: (_) =>
              WeatherBloc(const OpenMeteoWeatherStore())
                ..add(const WeatherRequested()),
        ),
        BlocProvider(
          create: (_) =>
              SensorBloc(const BleSensorStore())..add(const SensorRequested()),
        ),
        BlocProvider(create: (_) => DockBloc(const DockStore())),
        BlocProvider(
          create: (c) {
            final s = c.read<SettingsBloc>().state;
            return DisplayBloc(const DisplayStore())..add(
              DisplayScheduleSet(
                s.nightStartMin,
                s.nightEndMin,
                s.nightBrightness,
              ),
            );
          },
        ),
        BlocProvider(
          create: (c) {
            final s = c.read<SettingsBloc>().state;
            return DeviceBatteryBloc(DeviceBatteryStore())
              ..add(DeviceBatteryThresholdsSet(s.lowBatteryPct, s.overheatC))
              ..add(const DeviceBatteryRequested());
          },
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ClockBloc, ClockState>(
            listenWhen: (a, b) => a.now.minute != b.now.minute,
            listener: (c, s) =>
                c.read<DisplayBloc>().add(DisplayMinuteTicked(s.now)),
          ),
          BlocListener<SettingsBloc, SettingsState>(
            listenWhen: (a, b) =>
                a.nightStartMin != b.nightStartMin ||
                a.nightEndMin != b.nightEndMin ||
                a.nightBrightness != b.nightBrightness,
            listener: (c, s) => c.read<DisplayBloc>().add(
              DisplayScheduleSet(
                s.nightStartMin,
                s.nightEndMin,
                s.nightBrightness,
              ),
            ),
          ),
          BlocListener<SettingsBloc, SettingsState>(
            listenWhen: (a, b) => a.lowBatteryPct != b.lowBatteryPct || a.overheatC != b.overheatC,
            listener: (c, s) => c.read<DeviceBatteryBloc>().add(
              DeviceBatteryThresholdsSet(s.lowBatteryPct, s.overheatC),
            ),
          ),
          BlocListener<DeviceBatteryBloc, DeviceBatteryState>(
            listenWhen: (a, b) => a.overheat != b.overheat,
            listener: (c, s) => c.read<DisplayBloc>().add(DisplayOverheatChanged(s.overheat)),
          ),
          BlocListener<DisplayBloc, DisplayState>(
            listenWhen: (a, b) => a.night != b.night,
            listener: (c, s) => c.read<DeviceBatteryBloc>().add(
              DeviceBatteryNightChanged(s.night),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Smart Clock',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF141218),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFD0BCFF),
              brightness: Brightness.dark,
              primary: const Color(0xFFD0BCFF),
              secondary: const Color(0xFFEFB8C8),
              tertiary: const Color(0xFFB4E5BC),
              surface: const Color(0xFF1A181F),
              surfaceContainerHighest: const Color(0xFF2B2930),
            ),
            fontFamily: 'RobotoFlex',
            textTheme: Typography.material2021().white.apply(
              fontFamily: 'RobotoFlex',
              bodyColor: const Color(0xFFE6E0E9),
              displayColor: const Color(0xFFE6E0E9),
            ),
          ),
          home: const WallDisplay(),
        ),
      ),
    );
  }
}

/// Lays out the 1280x800 design and scales it to the screen.
class WallDisplay extends StatelessWidget {
  const WallDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return BlocSelector<DisplayBloc, DisplayState, bool>(
      selector: (s) => s.dim,
      builder: (context, dim) => MediaQuery(
        // Night/overheat: freeze the Loop animations (reuses the reduced-motion path).
        data: mq.copyWith(disableAnimations: mq.disableAnimations || dim),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _wall(),
            if (dim)
              const IgnorePointer(child: ColoredBox(color: Color(0x80000000))),
          ],
        ),
      ),
    );
  }

  Widget _wall() {
    return Scaffold(
      body: ColoredBox(
        color: const Color(0xFF141218),
        child: SizedBox.expand(
          child: FittedBox(
            child: SizedBox(
              width: 1280,
              height: 800,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 28,
                    ),
                    child: Column(
                      children: [
                        // Top row: HOME-launcher escape hatch on the left, battery indicators on the right
                        Row(
                          children: [
                            if (Platform.isAndroid)
                              Builder(
                                builder: (context) => IconButton(
                                  tooltip: 'Android home settings',
                                  icon: const Icon(
                                    Icons.settings_outlined,
                                    size: 28,
                                    color: Color(0x66E6E0E9),
                                  ),
                                  onPressed: () => context
                                      .read<SettingsBloc>()
                                      .add(const SettingsHomeAppPickerOpened()),
                                ),
                              ),
                            const Spacer(),
                            const _BatteryRow(),
                          ],
                        ),
                        const Expanded(
                          child: Row(
                            children: [
                              Expanded(flex: 175, child: LocalCard()),
                              SizedBox(width: 20),
                              Expanded(flex: 100, child: IndiaCard()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(height: 116, child: DockBar()),
                        const SizedBox(height: 20),
                        const SizedBox(height: 92, child: SensorStrip()),
                      ],
                    ),
                  ),
                  const Positioned(top: 28, right: 32, child: SettingsEntry()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _hot = Color(0xFFF44336);

/// Tablet battery (and overheat badge) and averaged sensor battery.
class _BatteryRow extends StatelessWidget {
  const _BatteryRow();

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
