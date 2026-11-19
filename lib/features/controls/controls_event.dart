part of 'controls_bloc.dart';

sealed class ControlsEvent {
  const ControlsEvent();
}

final class SceneSelected extends ControlsEvent {
  const SceneSelected(this.scene);
  final Scene scene;
}

final class DeviceToggled extends ControlsEvent {
  const DeviceToggled(this.device);
  final Device device;
}
