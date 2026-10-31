import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dock_bloc.dart';

const _icons = [
  (Icons.music_note, Color(0xFFD0BCFF), Color(0xFF381E72)),
  (Icons.graphic_eq, Color(0xFFB4E5BC), Color(0xFF0F3D1E)),
  (Icons.home_outlined, Color(0xFFEFB8C8), Color(0xFF492532)),
  (Icons.apps, Color(0xFFCCC2DC), Color(0xFF332D41)),
];

class DockBar extends StatelessWidget {
  const DockBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DockBloc>().state;
    return Row(
      children: [
        for (final (i, app) in state.apps.indexed) ...[
          if (i > 0) const SizedBox(width: 20),
          Expanded(
            child: Opacity(
              opacity: state.enabled ? 1 : 0.5,
              child: Material(
                color: const Color(0xFF2B2930),
                borderRadius: BorderRadius.circular(58),
                child: Tooltip(
                  message: app.label,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(58),
                    onTap: state.enabled
                        ? () =>
                              context.read<DockBloc>().add(DockAppPressed(app))
                        : null,
                    child: Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: _icons[i].$2,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _icons[i].$1,
                          size: 40,
                          color: _icons[i].$3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
