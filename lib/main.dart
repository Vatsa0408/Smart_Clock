
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'features/alarms/alarms_bloc.dart';
import 'features/alarms/view/ringing_overlay.dart';
import 'features/calendar/calendar_bloc.dart';
import 'features/calendar/calendar_store.dart';
import 'features/charge_control/charge_control_bloc.dart';
import 'features/charge_control/charge_control_store.dart';
import 'features/clock/clock_bloc.dart';
import 'features/clock/view/clock_cards.dart';
import 'features/controls/controls_bloc.dart';
import 'features/device_battery/device_battery_bloc.dart';
import 'features/device_battery/device_battery_store.dart';
import 'features/device_battery/view/low_battery_banner.dart';
import 'features/diagnostics/diagnostics_bloc.dart';
import 'features/diagnostics/diagnostics_store.dart';
import 'features/display/display_bloc.dart';
import 'features/display/display_store.dart';
import 'features/display/view/idle_dimmer.dart';
import 'features/display/view/night_overlay.dart';
import 'features/dock/dock_bloc.dart';
import 'features/dock/dock_store.dart';
import 'features/dock/view/dock_bar.dart';
import 'features/now_playing/now_playing_bloc.dart';
import 'features/now_playing/now_playing_store.dart';
import 'features/now_playing/view/now_playing_bar.dart';
import 'features/panel/panel_bloc.dart';
import 'features/panel/view/panel_sheet.dart';
import 'features/panel/view/tools_dock.dart';
import 'features/sensor/sensor_bloc.dart';
import 'features/settings/settings_bloc.dart';
import 'features/settings/settings_store.dart';
import 'features/sensor/sensor_store.dart';
import 'features/sensor/view/sensor_strip.dart';
import 'features/timers/timers_bloc.dart';
import 'features/todo/todo_bloc.dart';
import 'features/weather/weather_bloc.dart';
import 'features/weather/weather_store.dart';
import 'shared/idle_pager.dart';

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
        BlocProvider(create: (_) => AlarmsBloc()),
        BlocProvider(create: (_) => TimersBloc()),
        BlocProvider(create: (_) => TodoBloc()),
        BlocProvider(create: (_) => ControlsBloc()),
        BlocProvider(create: (_) => CalendarBloc(const CalendarStore())..add(const CalendarRequested())),
        BlocProvider(create: (_) => PanelBloc()),
        BlocProvider(
          create: (_) =>
              NowPlayingBloc(const NowPlayingStore())..add(const NowPlayingStarted()),
        ),
        BlocProvider(
          create: (c) {
            final s = c.read<SettingsBloc>().state;
            return DisplayBloc(const DisplayStore())
              ..add(
                DisplayScheduleSet(
                  s.nightStartMin,
                  s.nightEndMin,
                  s.nightBrightness,
                ),
              )
              ..add(DisplayOrbitSet(s.burnInOrbit))
              ..add(DisplayAutoSet(s.nightAuto));
          },
        ),
        BlocProvider(create: (_) => ChargeControlBloc(const ChargeControlStore())..add(const ChargeControlStarted())),
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
          BlocListener<ClockBloc, ClockState>(
            listenWhen: (a, b) => a.now.minute != b.now.minute,
            listener: (c, s) => c.read<AlarmsBloc>().add(AlarmMinuteTicked(s.now)),
          ),
          BlocListener<ClockBloc, ClockState>(
            listenWhen: (a, b) => a.now != b.now,
            listener: (c, _) => c.read<TimersBloc>().add(const TimersTicked()),
          ),
          BlocListener<AlarmsBloc, AlarmsState>(
            listenWhen: (a, b) => a.ringing == null && b.ringing != null,
            listener: (c, _) => c.read<PanelBloc>().add(const PanelClosed()),
          ),
          BlocListener<SettingsBloc, SettingsState>(
            listenWhen: (a, b) => a.nightAuto != b.nightAuto,
            listener: (c, s) => c.read<DisplayBloc>().add(DisplayAutoSet(s.nightAuto)),
          ),
          BlocListener<SettingsBloc, SettingsState>(
            listenWhen: (a, b) => a.burnInOrbit != b.burnInOrbit,
            listener: (c, s) => c.read<DisplayBloc>().add(DisplayOrbitSet(s.burnInOrbit)),
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
          BlocListener<DeviceBatteryBloc, DeviceBatteryState>(
            listenWhen: (a, b) => a.plugged != b.plugged || a.currentMa != b.currentMa || a.level != b.level,
            listener: (c, s) => c.read<ChargeControlBloc>().add(
              ChargeControlBatteryChanged(level: s.level, plugged: s.plugged, currentMa: s.currentMa),
            ),
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
        child: IdleDimmer(
         child: Stack(
          fit: StackFit.expand,
          children: [
            _wall(),
            if (dim)
              const IgnorePointer(child: ColoredBox(color: Color(0x80000000))),
          ],
         ),
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
                  BlocSelector<DisplayBloc, DisplayState, int>(
                    selector: (s) => s.shift,
                    builder: (_, i) => Transform.translate(
                      offset: orbitOffsets[i],
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                        child: Column(
                          spacing: 16,
                          children: [
                            Expanded(
                              child: IdlePager(
                                pages: [
                                  Row(
                                    spacing: 16,
                                    children: [
                                      Expanded(flex: 175, child: LocalCard()),
                                      Expanded(
                                        flex: 100,
                                        child: Column(
                                          spacing: 16,
                                          children: [
                                            Expanded(child: IndiaCard()),
                                            NowPlayingBar(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 100,
                              child: Row(
                                spacing: 12,
                                children: [Expanded(child: DockBar()), ToolsDock()],
                              ),
                            ),
                            SizedBox(height: 76, child: SensorStrip()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const PanelSheet(),
                  const NightOverlay(),
                  const LowBatteryBanner(),
                  const RingingOverlay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
