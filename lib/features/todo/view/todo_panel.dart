import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/ui.dart';
import '../todo_bloc.dart';

class TodoPanel extends StatefulWidget {
  const TodoPanel({super.key});

  @override
  State<TodoPanel> createState() => _TodoPanelState();
}

class _TodoPanelState extends State<TodoPanel> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _add(TodoBloc bloc) {
    bloc.add(TodoAdded(_text.text));
    if (!bloc.state.full) _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TodoBloc>();
    final s = context.watch<TodoBloc>().state;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 64,
                  child: TextField(
                    controller: _text,
                    maxLength: 40,
                    enabled: !s.full,
                    style: flex(26, 400, Colors.white),
                    onSubmitted: (_) => _add(bloc),
                    decoration: InputDecoration(
                      hintText: s.full ? 'List is full (${TodoState.maxItems} items)' : 'Add an item',
                      hintStyle: flex(26, 400, kOutline),
                      counterText: '',
                      filled: true,
                      fillColor: kSurfaceHi,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 28),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: const BorderSide(color: kSecondary, width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: const BorderSide(color: kSecondary, width: 2)),
                      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: const BorderSide(color: kSecondary, width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: const BorderSide(color: kPrimary, width: 3)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Btn(
                onTap: s.full ? null : () => _add(bloc),
                bg: kPrimary,
                fg: kOnPrimary,
                size: 24,
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (s.items.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 0),
              child: Text('Nothing to do. Add something above.', style: flex(26, 400, kMuted)),
            ),
          for (final t in s.items)
            Container(
              height: 64,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.only(left: 8, right: 12),
              decoration: BoxDecoration(color: kSurfaceHi, borderRadius: BorderRadius.circular(32)),
              child: Row(
                children: [
                  Btn(
                    onTap: () => bloc.add(TodoToggled(t.id)),
                    bg: t.done ? kPrimary : Colors.transparent,
                    fg: kOnPrimary,
                    width: 48,
                    height: 48,
                    border: BorderSide(color: t.done ? kPrimary : kOutline, width: 2),
                    semantics: 'Mark ${t.text} done',
                    child: t.done ? const Icon(Icons.check, size: 26) : const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      t.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: flex(28, 500, t.done ? kOutline : kText).copyWith(
                        decoration: t.done ? TextDecoration.lineThrough : null,
                        decorationColor: kOutline,
                      ),
                    ),
                  ),
                  Btn(
                    onTap: () => bloc.add(TodoRemoved(t.id)),
                    bg: Colors.transparent,
                    fg: kMuted,
                    width: 48,
                    height: 48,
                    semantics: 'Delete ${t.text}',
                    child: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
