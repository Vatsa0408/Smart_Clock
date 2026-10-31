part of 'dock_bloc.dart';

final class DockState extends Equatable {
  const DockState({required this.apps, required this.enabled});
  final List<DockApp> apps;
  final bool enabled;

  @override
  List<Object> get props => [apps, enabled];
}
