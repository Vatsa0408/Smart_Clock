import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_clock/features/clock/clock_bloc.dart';
import 'package:smart_clock/features/clock/clock_store.dart';
import 'package:smart_clock/features/clock/view/clock_cards.dart';
import 'package:smart_clock/features/weather/weather_bloc.dart';
import 'package:smart_clock/features/weather/weather_store.dart';

class _MockStorage extends Mock implements Storage {}

class _FakeStore extends ClockStore {
  _FakeStore(this.c);
  final StreamController<DateTime> c;
  @override
  Stream<DateTime> ticks() => c.stream;
}

void main() {
  for (final reduce in [false, true]) {
    testWidgets('seconds bar advances each tick (disableAnimations=$reduce)', (tester) async {
      await (FontLoader('RobotoFlex')
            ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/RobotoFlex.ttf').readAsBytesSync()))))
          .load();
      final storage = _MockStorage();
      when(() => storage.read(any())).thenReturn(null);
      when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
      HydratedBloc.storage = storage;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(disableAnimations: reduce);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final c = StreamController<DateTime>();
      addTearDown(c.close);
      await tester.pumpWidget(MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ClockBloc(store: _FakeStore(c))),
          BlocProvider(create: (_) => WeatherBloc(const SampleWeatherStore())),
        ],
        child: const MaterialApp(home: Scaffold(body: SizedBox(width: 800, height: 700, child: LocalCard()))),
      ));
      double width() => tester
          .getSize(find.descendant(of: find.byType(FractionallySizedBox), matching: find.byType(DecoratedBox)).last)
          .width;
      c.add(DateTime(2026, 1, 1, 12, 0, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1100));
      final w10 = width();
      c.add(DateTime(2026, 1, 1, 12, 0, 30));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1100));
      final w30 = width();
      expect(w30, greaterThan(w10));
      c.add(DateTime(2026, 1, 1, 12, 1, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1100));
      expect(width(), lessThan(w10));
      await tester.pumpWidget(const SizedBox());
    });
  }
}
