import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_clock/features/clock/clock_bloc.dart';
import 'package:smart_clock/features/dock/dock_bloc.dart';
import 'package:smart_clock/features/dock/dock_store.dart';
import 'package:smart_clock/features/sensor/sensor_bloc.dart';
import 'package:smart_clock/features/sensor/sensor_store.dart';
import 'package:smart_clock/features/weather/weather_bloc.dart';
import 'package:smart_clock/features/weather/weather_store.dart';
import 'package:smart_clock/main.dart';

class _MockStorage extends Mock implements Storage {}

void main() {
  testWidgets('wall display lays out and animates without errors', (tester) async {
    final font = FontLoader('RobotoFlex')
      ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/RobotoFlex.ttf').readAsBytesSync())));
    await font.load();
    final storage = _MockStorage();
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ClockBloc()),
        BlocProvider(create: (_) => WeatherBloc(const SampleWeatherStore())..add(const WeatherRequested())),
        BlocProvider(create: (_) => SensorBloc(const SampleSensorStore())),
        BlocProvider(create: (_) => DockBloc(const DockStore())),
      ],
      child: const MaterialApp(home: WallDisplay()),
    ));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Bangalore · India'), findsOneWidget);
    expect(find.text('YouTube Music'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
