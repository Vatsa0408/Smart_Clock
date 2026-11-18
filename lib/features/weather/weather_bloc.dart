import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../shared/backoff.dart';
import 'weather_store.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends HydratedBloc<WeatherEvent, WeatherState> {
  WeatherBloc(this._store, {this.retryBase = const Duration(seconds: 30)}) : super(const WeatherState()) {
    on<WeatherRequested>((e, emit) async {
      _retry?.cancel();
      try {
        final (local, bangalore) = await (_store.local(), _store.bangalore()).wait;
        _failures = 0;
        emit(WeatherState(local: local, bangalore: bangalore, fetchedAt: DateTime.now()));
      } catch (err) {
        debugPrint('Weather refresh failed: $err'); // -> diagnostics log
        emit(state.copyWith(error: true)); // keep the last good data
        _retry = Timer(backoff(_failures++, base: retryBase), () {
          if (!isClosed) add(const WeatherRequested());
        });
      }
    });
    _refresh = Timer.periodic(const Duration(minutes: 30), (_) => add(const WeatherRequested()));
  }

  final WeatherStore _store;
  final Duration retryBase;
  late final Timer _refresh;
  Timer? _retry;
  int _failures = 0;

  @override
  Future<void> close() {
    _refresh.cancel();
    _retry?.cancel();
    return super.close();
  }

  // Fixed so persisted state survives obfuscated release builds.
  @override
  String get storagePrefix => 'WeatherBloc';

  @override
  WeatherState? fromJson(Map<String, dynamic> json) {
    try {
      return WeatherState(
        local: Weather.fromJson(json['local'] as Map<String, dynamic>),
        bangalore: Weather.fromJson(json['bangalore'] as Map<String, dynamic>),
        fetchedAt: DateTime.tryParse(json['at'] as String? ?? ''),
      );
    } catch (_) {
      return null; // nothing cached yet or schema changed
    }
  }

  @override
  Map<String, dynamic>? toJson(WeatherState state) => switch (state) {
        WeatherState(:final local?, :final bangalore?) => {
            'local': local.toJson(),
            'bangalore': bangalore.toJson(),
            'at': state.fetchedAt?.toIso8601String(),
          },
        _ => null,
      };
}
