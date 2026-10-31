import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'weather_store.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc(this._store) : super(const WeatherState()) {
    on<WeatherRequested>((e, emit) async => emit(WeatherState(
          local: await _store.local(),
          bangalore: await _store.bangalore(),
        )));
  }

  final WeatherStore _store;
}
