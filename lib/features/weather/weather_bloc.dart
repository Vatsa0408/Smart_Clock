import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'weather_store.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends HydratedBloc<WeatherEvent, WeatherState> {
  WeatherBloc(this._store) : super(const WeatherState()) {
    on<WeatherRequested>((e, emit) async {
      try {
        final (local, bangalore) = await (_store.local(), _store.bangalore()).wait;
        emit(WeatherState(local: local, bangalore: bangalore, fetchedAt: DateTime.now()));
      } catch (_) {
        emit(state.copyWith(error: true)); // keep the last good data
      }
    });
    _refresh = Timer.periodic(const Duration(minutes: 30), (_) => add(const WeatherRequested()));
  }

  final WeatherStore _store;
  late final Timer _refresh;

  @override
  Future<void> close() {
    _refresh.cancel();
    return super.close();
  }

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
