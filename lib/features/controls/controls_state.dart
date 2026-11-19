part of 'controls_bloc.dart';

final class ControlsState extends Equatable {
  const ControlsState({this.scene, this.on = const {Device.living}});
  final Scene? scene;
  final Set<Device> on;

  @override
  List<Object?> get props => [scene, on];
}
