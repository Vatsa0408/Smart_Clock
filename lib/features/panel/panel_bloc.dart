import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'panel_event.dart';
part 'panel_state.dart';

/// Which bottom sheet is open (UI state shared by the chips, tools dock and sheet).
class PanelBloc extends Bloc<PanelEvent, PanelState> {
  PanelBloc() : super(const PanelState()) {
    on<PanelOpened>((e, emit) => emit(PanelState(e.panel)));
    on<PanelToggled>((e, emit) => emit(PanelState(state.panel == e.panel ? null : e.panel)));
    on<PanelClosed>((e, emit) => emit(const PanelState()));
  }
}
