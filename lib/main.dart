import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'features/clock/clock_bloc.dart';
import 'features/clock/view/clock_cards.dart';
import 'features/dock/dock_bloc.dart';
import 'features/dock/dock_store.dart';
import 'features/dock/view/dock_bar.dart';
import 'features/sensor/sensor_bloc.dart';
import 'features/sensor/sensor_store.dart';
import 'features/sensor/view/sensor_strip.dart';
import 'features/weather/weather_bloc.dart';
import 'features/weather/weather_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationSupportDirectory()).path,
    ),
  );
  runApp(const SmartClockApp());
}

class SmartClockApp extends StatelessWidget {
  const SmartClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ClockBloc()),
        BlocProvider(create: (_) => WeatherBloc(const SampleWeatherStore())..add(const WeatherRequested())),
        BlocProvider(create: (_) => SensorBloc(const SampleSensorStore())..add(const SensorRequested())),
        BlocProvider(create: (_) => DockBloc(const DockStore())),
      ],
      child: MaterialApp(
        title: 'Smart Clock',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF141218),
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFD0BCFF), brightness: Brightness.dark),
          textTheme: Typography.material2021().white.apply(
                bodyColor: const Color(0xFFE6E0E9),
                displayColor: const Color(0xFFE6E0E9),
              ),
        ),
        home: const WallDisplay(),
      ),
    );
  }
}

/// Lays out the 1280x800 design and scales it to the screen.
class WallDisplay extends StatelessWidget {
  const WallDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: FittedBox(
          child: SizedBox(
            width: 1280,
            height: 800,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: Column(
                children: [
                  const Expanded(
                    child: Row(children: [
                      Expanded(flex: 175, child: LocalCard()),
                      SizedBox(width: 20),
                      Expanded(flex: 100, child: IndiaCard()),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 116, child: DockBar()),
                  const SizedBox(height: 20),
                  const SizedBox(height: 72, child: SensorStrip()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
