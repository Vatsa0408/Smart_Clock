import 'dart:async';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

/// Swipeable pages that return to page 0 after [idle] without a pointer event.
/// UI-only state, so no bloc.
class IdlePager extends StatefulWidget {
  const IdlePager({super.key, required this.pages, this.idle = const Duration(seconds: 60)});

  final List<Widget> pages;
  final Duration idle;

  @override
  State<IdlePager> createState() => _IdlePagerState();
}

class _IdlePagerState extends State<IdlePager> {
  final _c = PageController();
  Timer? _t;
  int _page = 0;

  void _poke() {
    _t?.cancel();
    _t = Timer(widget.idle, () {
      if (mounted && _c.hasClients && _page != 0) {
        _c.animateToPage(0, duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (_) => _poke(),
        child: Stack(
          children: [
            ScrollConfiguration(
              // Windows: mouse drag does not scroll by default since Flutter 2.5.
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad},
              ),
              child: PageView(
                controller: _c,
                onPageChanged: (i) {
                  setState(() => _page = i);
                  _poke();
                },
                children: widget.pages,
              ),
            ),
            if (widget.pages.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < widget.pages.length; i++)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _page ? const Color(0xFFD0BCFF) : Colors.white24,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
}
