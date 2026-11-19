part of 'todo_bloc.dart';

sealed class TodoEvent {
  const TodoEvent();
}

final class TodoAdded extends TodoEvent {
  const TodoAdded(this.text);
  final String text;
}

final class TodoToggled extends TodoEvent {
  const TodoToggled(this.id);
  final int id;
}

final class TodoRemoved extends TodoEvent {
  const TodoRemoved(this.id);
  final int id;
}
