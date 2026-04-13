import 'package:bgk_ladies/bloc/event/event_bloc_events.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_state.dart';
import 'package:bgk_ladies/models/event_model.dart';
import 'package:bgk_ladies/services/event/event_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventBloc extends Bloc<EventBlocEvent, EventBlocState> {
  final EventService _service;
  String? _selectedEventId;

  EventBloc(this._service) : super(const EventStateInitial()) {
    on<EventBlocEventInitialize>((event, emit) async {
      await emit.forEach<List<EventModel>>(
        _service.getAllEvents(),
        onData: (events) {
          final activeEvents = events.where((e) => e.isactive).toList();
          return EventStateLoaded(
            allEvents: events,
            activeEvents: activeEvents,
            isLoading: false,
          );
        },
        onError: (error, stackTrace) =>
            EventStateCurrentEventDisabled(error.toString()),
      );
    });

    on<EventBlocEventSelectEvent>((event, emit) {
      _selectedEventId = event.eventId;
    });

    on<EventBlocEventUpdateList>((event, emit) {
      final activeEvents = event.allEvents
          .where((eventModel) => eventModel.isactive)
          .toList();

      // Check the edge case: Is our selected event still active?
      if (_selectedEventId != null) {
        bool stillActive = activeEvents.any(
          (eventModel) => eventModel.eventId == _selectedEventId,
        );
        if (!stillActive) {
          emit(
            const EventStateCurrentEventDisabled(
              "This event has been closed by an admin.",
            ),
          );
          return;
        }
      }

      emit(
        EventStateLoaded(
          allEvents: event.allEvents,
          activeEvents: activeEvents,
          isLoading: false,
        ),
      );
    });

    on<EventBlocEventUpdateTitle>((event, emit) async {
      await _service.updateEvent(
        eventId: event.eventId,
        eventName: event.newName,
      );
    });

    on<EventBlocEventReset>((event, emit) {
      _selectedEventId = null;
      emit(const EventStateInitial());
    });
  }
}
