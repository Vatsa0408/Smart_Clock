part of 'todo_bloc.dart';

final class TodoItem extends Equatable {
  const TodoItem(this.id, this.text, this.done);
  final int id;
  final String text;
  final bool done;

  @override
  List<Object> get props => [id, text, done];
}

final class TodoState extends Equatable {
  const TodoState({
    this.items = const [
      TodoItem(1, 'Groceries', false),
      TodoItem(2, 'Water plants', false),
      TodoItem(3, 'Pay electricity bill', true),
    ],
    this.seq = 4,
  });

  static const maxItems = 5;

  final List<TodoItem> items;
  final int seq;

  bool get full => items.length >= maxItems;
  int get open => items.where((t) => !t.done).length;

  TodoState copyWith({List<TodoItem>? items, int? seq}) => TodoState(items: items ?? this.items, seq: seq ?? this.seq);

  @override
  List<Object> get props => [items, seq];
}
