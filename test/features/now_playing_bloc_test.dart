import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_clock/features/now_playing/now_playing_bloc.dart';
import 'package:smart_clock/features/now_playing/now_playing_store.dart';

class _MockStore extends Mock implements NowPlayingStore {}

void main() {
  late _MockStore store;
  late StreamController<Map<Object?, Object?>> events;
  late NowPlayingBloc bloc;

  setUp(() {
    store = _MockStore();
    events = StreamController<Map<Object?, Object?>>();
    when(() => store.watch()).thenAnswer((_) => events.stream);
    when(() => store.transport(any())).thenAnswer((_) async {});
    when(() => store.openAccessSettings()).thenAnswer((_) async {});
    bloc = NowPlayingBloc(store)..add(const NowPlayingStarted());
  });
  tearDown(() async {
    await bloc.close();
    await events.close();
  });

  Future<void> push(Map<Object?, Object?> m) async {
    events.add(m);
    await pumpEventQueue();
  }

  test('denied and unsupported keep the strip hidden', () async {
    await push({'access': 'denied'});
    expect(bloc.state.access, NowPlayingAccess.denied);
    expect(bloc.state.visible, isFalse);
    await push({'access': 'unsupported'});
    expect(bloc.state.access, NowPlayingAccess.unsupported);
    expect(bloc.state.visible, isFalse);
  });

  test('granted track is visible; a payload without art keeps the previous art', () async {
    final art = Uint8List.fromList([1, 2, 3]);
    await push({'access': 'granted', 'title': 'Song', 'artist': 'Band', 'pkg': 'p', 'playing': true, 'art': art});
    expect(bloc.state.visible, isTrue);
    expect(bloc.state.art, art);
    await push({'access': 'granted', 'title': 'Song', 'artist': 'Band', 'pkg': 'p', 'playing': false});
    expect(bloc.state.playing, isFalse);
    expect(bloc.state.art, art);
  });

  test('transport and access events reach the store', () async {
    bloc.add(const NowPlayingTransportPressed('next'));
    bloc.add(const NowPlayingAccessRequested());
    await pumpEventQueue();
    verify(() => store.transport('next')).called(1);
    verify(() => store.openAccessSettings()).called(1);
  });
}
