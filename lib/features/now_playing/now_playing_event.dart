part of 'now_playing_bloc.dart';

sealed class NowPlayingEvent {
  const NowPlayingEvent();
}

final class NowPlayingStarted extends NowPlayingEvent {
  const NowPlayingStarted();
}

final class NowPlayingAccessRequested extends NowPlayingEvent {
  const NowPlayingAccessRequested();
}

final class NowPlayingTransportPressed extends NowPlayingEvent {
  const NowPlayingTransportPressed(this.action); // 'play' | 'pause' | 'next' | 'previous'
  final String action;
}
