import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../dock_bloc.dart';
import '../dock_store.dart';

/// Icon + badge colours per dock slot (design order: purple, rose, lilac).
const _slots = [
  (icon: Icons.music_note_rounded, bg: Color(0xFFD0BCFF), fg: Color(0xFF381E72)),
  (icon: Icons.graphic_eq_rounded, bg: Color(0xFFEFB8C8), fg: Color(0xFF492532)),
  (icon: Icons.home_outlined, bg: Color(0xFFCCC2DC), fg: Color(0xFF332D41)),
];

/// Spotify sits second in the store; the design's rose/home slots map by index.
class DockBar extends StatelessWidget {
  const DockBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DockBloc>().state;
    final apps = state.apps.take(3).toList();

    return Row(
      children: [
        for (final (i, app) in apps.indexed) ...[
          if (i > 0) const SizedBox(width: 20),
          Expanded(
            child: Rise(
              key: ValueKey(app.package),
              delay: Duration(milliseconds: 300 + 100 * i),
              duration: const Duration(milliseconds: 800),
              child: _DockItem(
                app: app,
                slot: _slots[i % _slots.length],
                phase: i * 2.3 / 7, // morph delays 0 / -2.3s / -4.6s
                onTap: state.enabled ? () => context.read<DockBloc>().add(DockAppPressed(app)) : null,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DockItem extends StatefulWidget {
  const _DockItem({required this.app, required this.slot, required this.phase, required this.onTap});
  final DockApp app;
  final ({IconData icon, Color bg, Color fg}) slot;
  final double phase;
  final VoidCallback? onTap;

  @override
  State<_DockItem> createState() => _DockItemState();
}

class _DockItemState extends State<_DockItem> {
  bool _hover = false, _pressed = false, _focus = false;

  @override
  Widget build(BuildContext context) {
    final slot = widget.slot;
    return FocusableActionDetector(
      enabled: widget.onTap != null,
      onShowHoverHighlight: (v) => setState(() => _hover = v),
      onShowFocusHighlight: (v) => setState(() => _focus = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => widget.onTap?.call()),
      },
      mouseCursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? .96 : 1,
          duration: const Duration(milliseconds: 180),
          curve: const Cubic(.2, 0, 0, 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 116,
            padding: const EdgeInsets.only(left: 20, right: 36),
            decoration: BoxDecoration(
              color: _hover ? const Color(0xFF36343B) : const Color(0xFF2B2930),
              borderRadius: BorderRadius.circular(58),
              border: Border.all(
                color: _focus ? const Color(0xFFD0BCFF) : Colors.transparent,
                width: 4,
              ),
            ),
            child: Row(
              children: [
                Loop(
                  builder: (_, s) => Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: slot.bg,
                      // morph: 50% <-> 30% radius, 7s
                      borderRadius: BorderRadius.circular(76 * (.5 - .2 * wave(s, 7, widget.phase))),
                    ),
                    child: Icon(slot.icon, size: 40, color: slot.fg),
                  ),
                ),
                const SizedBox(width: 22),
                Flexible(
                  child: Text(
                    widget.app.label,
                    overflow: TextOverflow.ellipsis,
                    style: flex(28, 600, const Color(0xFFE6E0E9)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
