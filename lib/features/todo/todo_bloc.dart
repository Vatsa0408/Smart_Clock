import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends HydratedBloc<TodoEvent, TodoState> {
  TodoBloc() : super(const TodoState()) {
    on<TodoAdded>((e, emit) {
      final text = e.text.trim();
      if (text.isEmpty || state.full) return;
      emit(state.copyWith(items: [...state.items, TodoItem(state.seq, text, false)], seq: state.seq + 1));
    });
    on<TodoToggled>((e, emit) => emit(state.copyWith(
          items: [for (final t in state.items) t.id == e.id ? TodoItem(t.id, t.text, !t.done) : t],
        )));
    on<TodoRemoved>((e, emit) => emit(state.copyWith(items: state.items.where((t) => t.id != e.id).toList())));
  }

  @override
  String get storagePrefix => 'TodoBloc';

  @override
  TodoState? fromJson(Map<String, dynamic> json) => TodoState(
        items: [
          for (final t in json['items'] as List)
            TodoItem((t as Map)['i'] as int, t['t'] as String, t['d'] as bool),
        ],
        seq: json['seq'] as int,
      );

  @override
  Map<String, dynamic>? toJson(TodoState state) => {
        'items': [for (final t in state.items) {'i': t.id, 't': t.text, 'd': t.done}],
        'seq': state.seq,
      };
}
