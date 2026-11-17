import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../now_playing_bloc.dart';

/// Compact 48 px strip: art, title / artist and prev, play/pause, next. Hidden until something plays.
class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NowPlayingBloc, NowPlayingState>(
      builder: (context, s) {
        if (!s.visible) return const SizedBox.shrink();
        void press(String a) => context.read<NowPlayingBloc>().add(NowPlayingTransportPressed(a));
        const fg = Color(0xFFE6E0E9);
        return SizedBox(
          height: 48,
          child: Row(
            children: [
              if (s.art != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(s.art!, width: 40, height: 40, fit: BoxFit.cover, gaplessPlayback: true),
                ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  s.artist == null ? s.title! : '${s.title} · ${s.artist}',
                  style: flex(20, 500, fg),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, color: fg),
                onPressed: () => press('previous'),
              ),
              IconButton(
                icon: Icon(s.playing ? Icons.pause : Icons.play_arrow, color: fg),
                onPressed: () => press(s.playing ? 'pause' : 'play'),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: fg),
                onPressed: () => press('next'),
              ),
            ],
          ),
        );
      },
    );
  }
}
