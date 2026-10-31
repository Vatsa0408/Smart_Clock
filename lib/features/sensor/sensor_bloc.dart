import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'sensor_store.dart';

part 'sensor_event.dart';
part 'sensor_state.dart';

class SensorBloc extends Bloc<SensorEvent, SensorState> {
  SensorBloc(this._store) : super(const SensorState()) {
    on<SensorRequested>(
        (e, emit) async => emit(SensorState(reading: await _store.read())));
  }

  final SensorStore _store;
}
