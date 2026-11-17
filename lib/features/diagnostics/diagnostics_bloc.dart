import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'diagnostics_store.dart';

part 'diagnostics_event.dart';
part 'diagnostics_state.dart';

class DiagnosticsBloc extends Bloc<DiagnosticsEvent, DiagnosticsState> {
  DiagnosticsBloc(this._store) : super(const DiagnosticsState()) {
    on<DiagnosticsOpened>((e, emit) async => emit(DiagnosticsState(lines: await _store.tail())));
    on<DiagnosticsCleared>((e, emit) async {
      await _store.clear();
      emit(const DiagnosticsState());
    });
  }

  final DiagnosticsStore _store;
}
