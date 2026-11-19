import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../display_bloc.dart';

/// Reports "no touch for [after]" to DisplayBloc (UI-only timer, like IdlePager).
class IdleDimmer extends StatefulWidget {
  const IdleDimmer({super.key, required this.child, this.after = const Duration(minutes: 2)});

  final Widget child;
  final Duration after;

  @override
  State<IdleDimmer> createState() => _IdleDimmerState();
}

class _IdleDimmerState extends State<IdleDimmer> {
  Timer? _t;
  bool _idle = false;

  void _poke() {
    if (_idle) context.read<DisplayBloc>().add(const DisplayIdleSet(false));
    _idle = false;
    _t?.cancel();
    _t = Timer(widget.after, () {
      if (!mounted) return;
      _idle = true;
      context.read<DisplayBloc>().add(const DisplayIdleSet(true));
    });
  }

  @override
  void initState() {
    super.initState();
    _poke();
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Listener(behavior: HitTestBehavior.translucent, onPointerDown: (_) => _poke(), child: widget.child);
}
