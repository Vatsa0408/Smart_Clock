import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dock_store.dart';

part 'dock_event.dart';
part 'dock_state.dart';

class DockBloc extends Bloc<DockEvent, DockState> {
  DockBloc(this._store)
      : super(DockState(apps: DockStore.apps, enabled: _store.supported)) {
    on<DockAppPressed>((e, emit) => _store.launch(e.app));
  }

  final DockStore _store;
}
