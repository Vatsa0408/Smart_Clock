part of 'dock_bloc.dart';

sealed class DockEvent {
  const DockEvent();
}

final class DockAppPressed extends DockEvent {
  const DockAppPressed(this.app);
  final DockApp app;
}
