import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'calendar_store.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc(this._store) : super(const CalendarState()) {
    on<CalendarRequested>((e, emit) async => emit(CalendarState(events: await _store.events())));
  }

  final CalendarStore _store;
}
