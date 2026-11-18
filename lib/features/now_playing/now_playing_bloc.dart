import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'now_playing_store.dart';

part 'now_playing_event.dart';
part 'now_playing_state.dart';

/// Plain Bloc: stale media info must not survive a restart.
class NowPlayingBloc extends Bloc<NowPlayingEvent, NowPlayingState> {
  NowPlayingBloc(this._store) : super(const NowPlayingState()) {
    on<NowPlayingStarted>(
      (e, emit) => emit.forEach<Map<Object?, Object?>>(
        _store.watch(),
        onData: (m) => state.merge(m), // a lambda: a `state.merge` tear-off would capture the first state
        onError: (err, _) {
          debugPrint('Now playing failed: $err');
          return state;
        },
      ),
    );
    on<NowPlayingTransportPressed>((e, _) => _store.transport(e.action));
    on<NowPlayingAccessRequested>((e, _) => _store.openAccessSettings());
  }

  final NowPlayingStore _store;
}
