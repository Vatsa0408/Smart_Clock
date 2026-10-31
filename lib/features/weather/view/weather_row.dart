import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../weather_bloc.dart';
import '../weather_store.dart';

/// Temp + condition + H/L row; [bangalore] picks which reading to show.
class WeatherRow extends StatelessWidget {
  const WeatherRow({
    super.key,
    required this.bangalore,
    required this.icon,
    required this.badge,
    required this.iconColor,
    required this.accent,
    required this.size,
  });

  final bool bangalore;
  final IconData icon;
  final Color badge;
  final Color iconColor;
  final Color accent;

  /// 1 for the large (local) variant, <1 for the compact one.
  final double size;

  @override
  Widget build(BuildContext context) {
    final big = size == 1;
    return BlocSelector<WeatherBloc, WeatherState, Weather?>(
      selector: (s) => bangalore ? s.bangalore : s.local,
      builder: (context, w) {
        if (w == null) return const SizedBox.shrink();
        return _AnimatedWeatherRow(
          key: ValueKey('${bangalore}_${w.temp}_${w.condition}'),
          big: big,
          icon: icon,
          badge: badge,
          iconColor: iconColor,
          accent: accent,
          temp: w.temp,
          condition: w.condition,
          high: w.high,
          low: w.low,
        );
      },
    );
  }
}

class _AnimatedWeatherRow extends StatefulWidget {
  const _AnimatedWeatherRow({
    super.key,
    required this.big,
    required this.icon,
    required this.badge,
    required this.iconColor,
    required this.accent,
    required this.temp,
    required this.condition,
    required this.high,
    required this.low,
  });

  final bool big;
  final IconData icon;
  final Color badge;
  final Color iconColor;
  final Color accent;
  final int temp;
  final String condition;
  final int high;
  final int low;

  @override
  State<_AnimatedWeatherRow> createState() => _AnimatedWeatherRowState();
}

class _AnimatedWeatherRowState extends State<_AnimatedWeatherRow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  int _prevTemp = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _prevTemp = widget.temp;
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedWeatherRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.temp != oldWidget.temp ||
        widget.condition != oldWidget.condition ||
        widget.high != oldWidget.high ||
        widget.low != oldWidget.low) {
      _prevTemp = oldWidget.temp;
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Row(
              children: [
                // Weather icon badge
                Container(
                  width: widget.big ? 112 : 88,
                  height: widget.big ? 112 : 88,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.badge,
                        Color.lerp(widget.badge, Colors.black, 0.2)!,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.badge.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Subtle inner highlight
                      Container(
                        width: widget.big ? 100 : 78,
                        height: widget.big ? 100 : 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: Alignment.topLeft,
                            radius: 1.2,
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Icon(widget.icon, size: widget.big ? 64 : 50, color: widget.iconColor),
                    ],
                  ),
                ),
                SizedBox(width: widget.big ? 28 : 22),
                // Temperature
                Text(
                  '${widget.temp}°',
                  style: TextStyle(
                    fontSize: widget.big ? 88 : 72,
                    height: 0.92,
                    fontWeight: FontWeight.w700,
                    letterSpacing: widget.big ? -2.6 : -2.2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: widget.big ? 28 : 22),
                // Condition + H/L
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.condition,
                      style: TextStyle(
                        fontSize: widget.big ? 30 : 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'H ${widget.high}° · L ${widget.low}°',
                      style: TextStyle(
                        fontSize: widget.big ? 22 : 20,
                        fontWeight: FontWeight.w500,
                        color: widget.accent,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}