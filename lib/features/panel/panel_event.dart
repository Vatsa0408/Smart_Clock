part of 'panel_bloc.dart';

enum PanelKind { alarms, timers, controls, todo, night, forecast, calendar }

sealed class PanelEvent {
  const PanelEvent();
}

final class PanelOpened extends PanelEvent {
  const PanelOpened(this.panel);
  final PanelKind panel;
}

/// Tool button: open it, or close it when already open.
final class PanelToggled extends PanelEvent {
  const PanelToggled(this.panel);
  final PanelKind panel;
}

final class PanelClosed extends PanelEvent {
  const PanelClosed();
}
