part of 'now_playing_bloc.dart';

enum NowPlayingAccess { unknown, denied, unsupported, granted }

final class NowPlayingState extends Equatable {
  const NowPlayingState({
    this.access = NowPlayingAccess.unknown,
    this.pkg,
    this.title,
    this.artist,
    this.playing = false,
    this.art,
  });

  final NowPlayingAccess access;
  final String? pkg, title, artist;
  final bool playing;
  final Uint8List? art;

  bool get visible => access == NowPlayingAccess.granted && title != null;

  /// Maps the native payload. Strings, not enum names, so obfuscation cannot break it.
  /// A missing `art` key keeps the previous art.
  NowPlayingState merge(Map<Object?, Object?> m) => NowPlayingState(
        access: switch (m['access']) {
          'granted' => NowPlayingAccess.granted,
          'denied' => NowPlayingAccess.denied,
          'unsupported' => NowPlayingAccess.unsupported,
          _ => NowPlayingAccess.unknown,
        },
        pkg: m['pkg'] as String?,
        title: m['title'] as String?,
        artist: m['artist'] as String?,
        playing: m['playing'] as bool? ?? false,
        art: m.containsKey('art') ? m['art'] as Uint8List? : art,
      );

  @override
  List<Object?> get props => [access, pkg, title, artist, playing, art];
}
