import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'mibeacon.dart';
import 'sensor_store.dart';

part 'sensor_event.dart';
part 'sensor_state.dart';

class SensorBloc extends HydratedBloc<SensorEvent, SensorState> {
  SensorBloc(this._store) : super(const SensorState()) {
    on<SensorRequested>(_onRequested);
  }

  final SensorStore _store;

  Future<void> _onRequested(SensorRequested e, Emitter<SensorState> emit) async {
    final config = await _store.loadConfig();
    final rooms = [for (final r in state.rooms) r.withConfig(config[r.name])];
    emit(SensorState(rooms: rooms));
    final keys = {for (final r in rooms) if (r.configured) r.mac: hexKey(r.key)};
    if (keys.isEmpty) return;
    await emit.forEach<MiValues>(
      _store.watch(keys),
      onData: (v) => SensorState(rooms: [
        for (final r in state.rooms) r.mac == v.mac ? r.merge(v) : r,
      ]),
      onError: (err, _) {
        debugPrint('Sensor scan failed: $err'); // Bluetooth off, no permission, no adapter
        return state;
      },
    );
  }

  @override
  SensorState? fromJson(Map<String, dynamic> json) => SensorState(rooms: [
        for (final r in json['rooms'] as List)
          RoomSensor.fromJson((r as Map).cast<String, dynamic>()),
      ]);

  @override
  Map<String, dynamic>? toJson(SensorState state) =>
      {'rooms': [for (final r in state.rooms) r.toJson()]};
}
