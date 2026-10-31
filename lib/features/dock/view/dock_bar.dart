import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dock_bloc.dart';

const _appConfigs = [
  DockAppConfig(
    label: 'YouTube Music',
    icon: Icons.music_note,
    gradient: [Color(0xFFD0BCFF), Color(0xFFB4A0E6)],
    iconColor: Color(0xFF381E72),
    glowColor: Color(0xFFD0BCFF),
  ),
  DockAppConfig(
    label: 'Spotify',
    icon: Icons.graphic_eq,
    gradient: [Color(0xFFB4E5BC), Color(0xFF93D59A)],
    iconColor: Color(0xFF0F3D1E),
    glowColor: Color(0xFF1DB954),
  ),
  DockAppConfig(
    label: 'Google Home',
    icon: Icons.home_outlined,
    gradient: [Color(0xFFEFB8C8), Color(0xFFE8A3B5)],
    iconColor: Color(0xFF492532),
    glowColor: Color(0xFFEFB8C8),
  ),
];

class DockAppConfig {
  const DockAppConfig({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.iconColor,
    required this.glowColor,
  });

  final String label;
  final IconData icon;
  final List<Color> gradient;
  final Color iconColor;
  final Color glowColor;
}

/// Individual animated dock item with scale and glow effects.
class _DockItem extends StatefulWidget {
  const _DockItem({
    super.key,
    required this.config,
    required this.enabled,
    required this.onTap,
    required this.index,
  });

  final DockAppConfig config;
  final bool enabled;
  final VoidCallback onTap;
  final int index;

  @override
  State<_DockItem> createState() => _DockItemState();
}

class _DockItemState extends State<_DockItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (!widget.enabled) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleHover(bool hovering) {
    if (!widget.enabled) return;
    setState(() => _isHovered = hovering);
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final isActive = widget.enabled && (_isPressed || _isHovered);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = _scaleAnimation.value;
        final glowOpacity = _glowAnimation.value * (isActive ? 1.0 : 0.0);

        return Transform.scale(
          scale: scale,
          child: MouseRegion(
            onEnter: (_) => _handleHover(true),
            onExit: (_) => _handleHover(false),
            cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: Opacity(
                opacity: widget.enabled ? 1.0 : 0.5,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(64),
                    boxShadow: [
                      if (widget.enabled && glowOpacity > 0)
                        BoxShadow(
                          color: config.glowColor.withOpacity(0.3 * glowOpacity),
                          blurRadius: 24 * glowOpacity,
                          spreadRadius: 4 * glowOpacity,
                          offset: const Offset(0, 4),
                        ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(64),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: config.gradient,
                            ),
                          ),
                        ),
                        // Subtle inner glow
                        if (widget.enabled)
                          Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.topLeft,
                                radius: 1.5,
                                colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        // Icon
                        Icon(
                          config.icon,
                          size: 44,
                          color: config.iconColor,
                        ),
                        // Pressed overlay
                        if (_isPressed)
                          Container(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        // Disabled overlay
                        if (!widget.enabled)
                          Container(
                            color: Colors.black.withOpacity(0.3),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DockBar extends StatelessWidget {
  const DockBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DockBloc>().state;

    // Limit to 3 apps (YouTube Music, Spotify, Google Home)
    final apps = state.apps.take(3).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (i, app) in apps.indexed) ...[
          if (i > 0) const SizedBox(width: 28),
          _DockItem(
            key: ValueKey(app.package),
            config: _appConfigs[i % _appConfigs.length],
            enabled: state.enabled,
            onTap: () => context.read<DockBloc>().add(DockAppPressed(app)),
            index: i,
          ),
        ],
      ],
    );
  }
}