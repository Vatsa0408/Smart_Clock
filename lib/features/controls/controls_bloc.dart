import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'controls_store.dart';

part 'controls_event.dart';
part 'controls_state.dart';

class ControlsBloc extends Bloc<ControlsEvent, ControlsState> {
  ControlsBloc() : super(const ControlsState()) {
    on<SceneSelected>((e, emit) {
      final on = {...state.on};
      for (final d in sceneInfo[e.scene]!.$3.entries) {
        d.value ? on.add(d.key) : on.remove(d.key);
      }
      emit(ControlsState(scene: e.scene, on: on));
    });
    on<DeviceToggled>((e, emit) {
      final on = {...state.on};
      if (!on.remove(e.device)) on.add(e.device);
      emit(ControlsState(on: on)); // a manual change leaves the scene
    });
  }
}
