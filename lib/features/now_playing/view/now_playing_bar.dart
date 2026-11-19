import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../now_playing_bloc.dart';

const _apps = {
  'com.google.android.apps.youtube.music': 'YouTube Music',
  'com.spotify.music': 'Spotify',
};

/// Now-playing card (108 px): spinning art badge, title, equaliser + artist/app, transport buttons.
/// Shows "Nothing playing" with disabled buttons until a media session is active.
class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Rise(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 800),
      child: BlocBuilder<NowPlayingBloc, NowPlayingState>(
        builder: (context, s) {
          final on = s.visible;
          void press(String a) => context.read<NowPlayingBloc>().add(NowPlayingTransportPressed(a));
          return Semantics(
            label: 'Now playing',
            child: Container(
              height: 108,
              padding: const EdgeInsets.fromLTRB(18, 0, 16, 0),
              decoration: BoxDecoration(color: kSecondary, borderRadius: BorderRadius.circular(40)),
              child: Row(
                children: [
                  _Art(s.art),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          on ? s.title! : 'Nothing playing',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: flex(22, 600, Colors.white, height: 1.1),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (on && s.playing) ...[const _Eq(), const SizedBox(width: 8)],
                            Flexible(
                              child: Text(
                                on ? (s.artist ?? _apps[s.pkg] ?? '') : 'Start music in an app below',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: flex(16, 500, const Color(0xFFCCC2DC)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Btn(
                    onTap: on ? () => press('previous') : null,
                    bg: Colors.transparent,
                    fg: kOnSecondary,
                    width: 46,
                    height: 46,
                    semantics: 'Previous track',
                    child: const Icon(Icons.skip_previous_rounded, size: 30),
                  ),
                  const SizedBox(width: 6),
                  Btn(
                    onTap: on ? () => press(s.playing ? 'pause' : 'play') : null,
                    bg: kOnSecondary,
                    fg: const Color(0xFF1D192B),
                    width: 58,
                    height: 58,
                    semantics: 'Play or pause',
                    child: Icon(s.playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 32),
                  ),
                  const SizedBox(width: 6),
                  Btn(
                    onTap: on ? () => press('next') : null,
                    bg: Colors.transparent,
                    fg: kOnSecondary,
                    width: 46,
                    height: 46,
                    semantics: 'Next track',
                    child: const Icon(Icons.skip_next_rounded, size: 30),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 64 px badge: album art when there is one, else the slowly spinning blob with a note.
class _Art extends StatelessWidget {
  const _Art(this.art);
  final Uint8List? art;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 64,
        height: 64,
        child: art != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(art!, fit: BoxFit.cover, gaplessPlayback: true),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  Loop(
                    builder: (_, s) => CustomPaint(size: const Size.square(64), painter: _BlobPainter(s)),
                  ),
                  const Icon(Icons.music_note_rounded, size: 30, color: kOnPrimary),
                ],
              ),
      );
}

class _BlobPainter extends CustomPainter {
  const _BlobPainter(this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    canvas.translate(51.21, 50);
    canvas.rotate(2 * math.pi * s / 36); // 36 s per turn, like the weather badge
    canvas.translate(-51.21, -50);
    canvas.drawPath(blobPath, Paint()..color = kPrimary);
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.s != s;
}

/// Three-bar equaliser (eq 0.9 s, bars offset by 0.3 s).
class _Eq extends StatelessWidget {
  const _Eq();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 14,
        child: Loop(
          builder: (_, s) => Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 3),
                Container(
                  width: 4,
                  height: 14 * (.3 + .7 * wave(s, .9, -.3 * i / .9)),
                  decoration: BoxDecoration(color: const Color(0xFFCCC2DC), borderRadius: BorderRadius.circular(2)),
                ),
              ],
            ],
          ),
        ),
      );
}
