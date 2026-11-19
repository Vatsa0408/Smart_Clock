part of 'panel_bloc.dart';

final class PanelState extends Equatable {
  const PanelState([this.panel]);
  final PanelKind? panel;

  @override
  List<Object?> get props => [panel];
}
