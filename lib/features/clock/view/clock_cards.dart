import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../weather/view/weather_row.dart';
import '../clock_bloc.dart';

const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _months = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December',
];

String _pad(int n) => n.toString().padLeft(2, '0');

(String time, String ampm) _format(DateTime t, bool hour24) {
  if (hour24) return ('${_pad(t.hour)}:${_pad(t.minute)}', '');
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return ('$h:${_pad(t.minute)}', t.hour < 12 ? 'AM' : 'PM');
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, this.bg, this.fg);
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        padding: const EdgeInsets.only(left: 16, right: 20),
        decoration: BoxDecoration(
          color: bg.withOpacity(0.9),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: bg.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_outlined, size: 20, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: fg,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      );
}

class _Time extends StatelessWidget {
  const _Time({
    required this.time,
    required this.ampm,
    required this.timeSize,
    required this.ampmSize,
    required this.ampmColor,
    required this.textColor,
  });
  final String time;
  final String ampm;
  final double timeSize;
  final double ampmSize;
  final Color ampmColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: timeSize,
              height: 0.92,
              fontWeight: FontWeight.w700,
              letterSpacing: -timeSize * 0.05,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: textColor,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          if (ampm.isNotEmpty) ...[
            SizedBox(width: timeSize > 200 ? 16 : 10),
            Text(
              ampm,
              style: TextStyle(
                fontSize: ampmSize,
                fontWeight: FontWeight.w600,
                color: ampmColor,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ],
      );
}

/// Animated time widget that smoothly transitions on time change.
class _AnimatedTime extends StatefulWidget {
  const _AnimatedTime({
    required this.time,
    required this.ampm,
    required this.timeSize,
    required this.ampmSize,
    required this.ampmColor,
    required this.textColor,
  });

  final String time;
  final String ampm;
  final double timeSize;
  final double ampmSize;
  final Color ampmColor;
  final Color textColor;

  @override
  State<_AnimatedTime> createState() => _AnimatedTimeState();
}

class _AnimatedTimeState extends State<_AnimatedTime> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _textColorOpacity;

  String _prevTime = '';
  String _prevAmpm = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _textColorOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _prevTime = widget.time;
    _prevAmpm = widget.ampm;
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.time != oldWidget.time || widget.ampm != oldWidget.ampm) {
      _prevTime = oldWidget.time;
      _prevAmpm = oldWidget.ampm;
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
            child: _Time(
                time: widget.time,
                ampm: widget.ampm,
                timeSize: widget.timeSize,
                ampmSize: widget.ampmSize,
                ampmColor: widget.ampmColor,
                textColor: Color.lerp(
                  const Color(0x00FFFFFF),
                  Colors.white,
                  _textColorOpacity.value,
                ) ?? Colors.white,
              ),
          ),
        );
      },
    );
  }
}

class LocalCard extends StatelessWidget {
  const LocalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => context.read<ClockBloc>().add(const ClockFormatToggled()),
      child: _ClockCard(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5E42A6),
            Color(0xFF4F378B),
            Color(0xFF3D2A6B),
          ],
        ),
        accentColor: const Color(0xFFD0BCFF),
        accentColorDark: const Color(0xFF381E72),
        padding: const EdgeInsets.fromLTRB(44, 36, 44, 40),
        borderRadius: BorderRadius.circular(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Location pill + Date
            BlocSelector<ClockBloc, ClockState, DateTime>(
              selector: (s) => s.now,
              builder: (_, now) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _Pill('Current location', Color(0xFFD0BCFF), Color(0xFF381E72)),
                  Text(
                    '${_days[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFEADDFF),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            // Center: Animated Time
            BlocBuilder<ClockBloc, ClockState>(
              buildWhen: (prev, curr) =>
                  prev.now != curr.now || prev.hour24 != curr.hour24,
              builder: (_, s) {
                final (t, ap) = _format(s.now, s.hour24);
                return _AnimatedTime(
                  time: t,
                  ampm: ap,
                  timeSize: 240,
                  ampmSize: 44,
                  ampmColor: const Color(0xFFD0BCFF),
                  textColor: Colors.white,
                );
              },
            ),
            // Bottom: Weather
            const WeatherRow(
              bangalore: false,
              icon: Icons.wb_cloudy_outlined,
              badge: Color(0xFFD0BCFF),
              iconColor: Color(0xFF381E72),
              accent: Color(0xFFD0BCFF),
              size: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class IndiaCard extends StatelessWidget {
  const IndiaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _ClockCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF7A4A5A),
          Color(0xFF633B48),
          Color(0xFF4A2E3A),
        ],
      ),
      accentColor: const Color(0xFFEFB8C8),
      accentColorDark: const Color(0xFF492532),
      padding: const EdgeInsets.fromLTRB(44, 36, 40, 40),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(64),
        topRight: Radius.circular(64),
        bottomRight: Radius.circular(64),
        bottomLeft: Radius.circular(160),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Pill('Bangalore · India', Color(0xFFEFB8C8), Color(0xFF492532)),
          BlocBuilder<ClockBloc, ClockState>(
            buildWhen: (prev, curr) =>
                prev.india != curr.india || prev.hour24 != curr.hour24,
            builder: (_, s) {
              final (t, ap) = _format(s.india, s.hour24);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AnimatedTime(
                    time: t,
                    ampm: ap,
                    timeSize: 128,
                    ampmSize: 30,
                    ampmColor: const Color(0xFFEFB8C8),
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'IST · ${s.indiaOffset}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFEFB8C8),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              );
            },
          ),
          const WeatherRow(
            bangalore: true,
            icon: Icons.grain,
            badge: Color(0xFFEFB8C8),
            iconColor: Color(0xFF492532),
            accent: Color(0xFFEFB8C8),
            size: 0.8,
          ),
        ],
      ),
    );
  }
}

/// A reusable clock card with gradient background and subtle effects.
class _ClockCard extends StatelessWidget {
  const _ClockCard({
    required this.gradient,
    required this.accentColor,
    required this.accentColorDark,
    required this.padding,
    required this.borderRadius,
    required this.child,
  });

  final LinearGradient gradient;
  final Color accentColor;
  final Color accentColorDark;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: accentColor.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: accentColor.withOpacity(0.9)),
        child: child,
      ),
    );
  }
}