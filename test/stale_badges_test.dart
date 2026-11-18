import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_clock/features/clock/clock_bloc.dart';
import 'package:smart_clock/features/sensor/sensor_bloc.dart';
import 'package:smart_clock/features/sensor/sensor_store.dart';
import 'package:smart_clock/features/sensor/view/sensor_strip.dart';
import 'package:smart_clock/features/weather/view/weather_row.dart';
import 'package:smart_clock/features/weather/weather_bloc.dart';
import 'package:smart_clock/features/weather/weather_store.dart';

class _MockStorage extends Mock implements Storage {}

void main() {
  late _MockStorage storage;
  setUp(() {
    storage = _MockStorage();
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  void bigView(WidgetTester t) {
    t.view.physicalSize = const Size(1280, 800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
  }

  Widget host(Widget child, List<BlocProvider> extra) => MultiBlocProvider(
        providers: [BlocProvider<ClockBloc>(create: (_) => ClockBloc()), ...extra],
        child: MaterialApp(home: Scaffold(body: SizedBox(width: 1280, height: 300, child: child))),
      );

  testWidgets('sensor older than 30 min keeps its value and shows its age', (tester) async {
    bigView(tester);
    final seen = DateTime.now().subtract(const Duration(minutes: 42)).toIso8601String();
    when(() => storage.read(any(that: startsWith('SensorBloc')))).thenReturn(<String, dynamic>{
      'rooms': <dynamic>[
        <String, dynamic>{'name': 'Living Room', 't': 21.5, 'h': 48.0, 'b': 80, 'seen': seen},
      ],
    });
    await tester.pumpWidget(host(
      const SensorStrip(),
      [BlocProvider<SensorBloc>(create: (_) => SensorBloc(const SampleSensorStore()))],
    ));
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('42 min ago'), findsOneWidget);
    expect(find.text('21.5°C'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('weather older than 45 min says when it was updated', (tester) async {
    bigView(tester);
    final at = DateTime.now().subtract(const Duration(hours: 2)).toIso8601String();
    const w = Weather(11, 'Rain', 11, 8);
    when(() => storage.read(any(that: startsWith('WeatherBloc'))))
        .thenReturn(<String, dynamic>{'local': w.toJson(), 'bangalore': w.toJson(), 'at': at});
    await tester.pumpWidget(host(
      const WeatherRow(bangalore: false),
      [BlocProvider<WeatherBloc>(create: (_) => WeatherBloc(const SampleWeatherStore()))],
    ));
    await tester.pump();
    expect(find.text('Updated 2 h ago'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
