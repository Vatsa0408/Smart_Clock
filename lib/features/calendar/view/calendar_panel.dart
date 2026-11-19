import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../../clock/clock_bloc.dart';
import '../calendar_bloc.dart';
import '../calendar_store.dart';

/// Today / Tomorrow event list; the next event is highlighted.
class CalendarPanel extends StatelessWidget {
  const CalendarPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final hour24 = context.select((ClockBloc b) => b.state.hour24);
    final now = context.select((ClockBloc b) => b.state.now);
    final cal = context.watch<CalendarBloc>().state;
    final next = cal.next(now);
    return ListView(
      children: [
        for (final (day, title) in [(0, 'Today'), (1, 'Tomorrow')]) ...[
          SectionLabel(title, top: 6),
          const SizedBox(height: 10),
          for (final e in cal.events.where((e) => e.day == day))
            _Row(e, hour24: hour24, next: identical(e, next)),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.e, {required this.hour24, required this.next});
  final CalendarItem e;
  final bool hour24, next;

  @override
  Widget build(BuildContext context) {
    final fg = next ? const Color(0xFFEADDFF) : kText;
    return Container(
      height: 68,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(left: 12, right: 28),
      decoration: BoxDecoration(color: next ? const Color(0xFF4F378B) : kSurfaceHi, borderRadius: BorderRadius.circular(34)),
      child: Row(
        children: [
          Container(
            width: 128,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: next ? kPrimary : kSecondary, borderRadius: BorderRadius.circular(23)),
            child: Text(hm(e.h, e.m, hour24), style: flex(24, 600, next ? kOnPrimary : kOnSecondary, tabular: true)),
          ),
          const SizedBox(width: 24),
          Expanded(child: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: flex(28, 500, fg))),
          if (next) Text('NEXT', style: flex(18, 700, fg, em: .04)),
        ],
      ),
    );
  }
}
