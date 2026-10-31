import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../clock/clock_bloc.dart';
import '../sensor_bloc.dart';
import '../sensor_store.dart';

/// Readings older than this are shown as "--".
const _staleAfter = Duration(minutes: 30);

const _roomConfigs = {
  'Living Room': RoomConfig(
    icon: Icons.living_outlined,
    gradient: [Color(0xFFEFB8C8), Color(0xFFE8A3B5)],
    iconColor: Color(0xFF492532),
    glowColor: Color(0xFFEFB8C8),
  ),
  'Bedroom': RoomConfig(
    icon: Icons.bed_outlined,
    gradient: [Color(0xFFD0BCFF), Color(0xFFB4A0E6)],
    iconColor: Color(0xFF381E72),
    glowColor: Color(0xFFD0BCFF),
  ),
  'Office': RoomConfig(
    icon: Icons.desk_outlined,
    gradient: [Color(0xFFB4E5BC), Color(0xFF93D59A)],
    iconColor: Color(0xFF0F3D1E),
    glowColor: Color(0xFF1DB954),
  ),
};

class RoomConfig {
  const RoomConfig({
    required this.icon,
    required this.gradient,
    required this.iconColor,
    required this.glowColor,
  });

  final IconData icon;
  final List<Color> gradient;
  final Color iconColor;
  final Color glowColor;
}

/// Animated sensor badge with pulse effect for fresh data.
class _AnimatedBadge extends StatefulWidget {
  const _AnimatedBadge({
    required this.icon,
    required this.gradient,
    required this.iconColor,
    required this.glowColor,
    required this.fresh,
  });

  final IconData icon;
  final List<Color> gradient;
  final Color iconColor;
  final Color glowColor;
  final bool fresh;

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.fresh) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fresh != oldWidget.fresh) {
      if (widget.fresh) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.fresh ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.gradient,
              ),
              shape: BoxShape.circle,
              boxShadow: widget.fresh
                  ? [
                      BoxShadow(
                        color: widget.glowColor.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(widget.icon, size: 22, color: widget.iconColor),
          ),
        );
      },
    );
  }
}

/// Animated value that transitions smoothly on change.
class _AnimatedValue extends StatefulWidget {
  const _AnimatedValue({
    required this.value,
    required this.unit,
    required this.fresh,
  });

  final String value;
  final String unit;
  final bool fresh;

  @override
  State<_AnimatedValue> createState() => _AnimatedValueState();
}

class _AnimatedValueState extends State<_AnimatedValue> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  String _prevValue = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _prevValue = widget.value;
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _prevValue = oldWidget.value;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  widget.value,
                  style: TextStyle(
                    fontSize: 38,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.76,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: widget.fresh ? Colors.white : const Color(0xFF6E6B7A),
                    shadows: widget.fresh
                        ? [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.unit,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: widget.fresh ? Colors.white.withOpacity(0.7) : const Color(0xFF6E6B7A),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SensorStrip extends StatelessWidget {
  const SensorStrip({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild once a minute (reuses the clock ticker) so stale readings expire.
    context.select((ClockBloc b) => b.state.now.minute);
    final rooms = context.select((SensorBloc b) => b.state.rooms);
    final now = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (i, r) in rooms.indexed) ...[
          if (i > 0) const SizedBox(width: 24),
          Expanded(child: _RoomCard(r, fresh: r.seenAt != null && now.difference(r.seenAt!) < _staleAfter)),
        ],
      ],
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard(this.room, {required this.fresh});
  final RoomSensor room;
  final bool fresh;

  @override
  Widget build(BuildContext context) {
    final config = _roomConfigs[room.name] ??
        RoomConfig(
          icon: Icons.sensors_outlined,
          gradient: [const Color(0xFFCCC2DC), const Color(0xFFB8B0CC)],
          iconColor: const Color(0xFF332D41),
          glowColor: const Color(0xFFCCC2DC),
        );

    final t = fresh ? room.temperature : null;
    final h = fresh ? room.humidity : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A181F),
        borderRadius: BorderRadius.circular(48),
        border: Border.all(
          color: fresh ? config.glowColor.withOpacity(0.2) : const Color(0xFF2B2930),
          width: 1,
        ),
        boxShadow: [
          if (fresh)
            BoxShadow(
              color: config.glowColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Room icon badge
          _AnimatedBadge(
            icon: config.icon,
            gradient: config.gradient,
            iconColor: config.iconColor,
            glowColor: config.glowColor,
            fresh: fresh,
          ),
          const SizedBox(width: 16),
          // Room name
          Expanded(
            child: Text(
              room.name,
              style: TextStyle(
                fontSize: 20,
                height: 1,
                fontWeight: FontWeight.w600,
                color: fresh ? const Color(0xFFE6E0E9) : const Color(0xFF6E6B7A),
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          // Temperature
          _AnimatedValue(
            value: t == null ? '--' : t.toStringAsFixed(1),
            unit: '°C',
            fresh: fresh,
          ),
          const SizedBox(width: 24),
          // Humidity
          _AnimatedValue(
            value: h == null ? '--' : h.round().toString(),
            unit: '%',
            fresh: fresh,
          ),
        ],
      ),
    );
  }
}