import 'package:bgk_ladies/bloc/event/event_bloc_events.dart';
import 'package:bgk_ladies/bloc/event/event_bloc_state.dart';
import 'package:bgk_ladies/models/event_model.dart';
import 'package:bgk_ladies/services/event/event_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventBloc extends Bloc<EventBlocEvent, EventBlocState> {
  final EventService _service;
  // ignore: unused_field
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

    on<EventBlocEventCreate>((event, emit) async {
      // 1. Lock the UI
      if (state is EventStateLoaded) {
        emit((state as EventStateLoaded).copyWith(isLoading: true));
      }

      try {
        await _service.createEvent(eventName: event.eventName);

        // 2. Unlock the UI (The stream might also trigger an unlock, which is fine)
        if (state is EventStateLoaded) {
          emit((state as EventStateLoaded).copyWith(isLoading: false));
        }
      } catch (e) {
        emit(EventBlocStateError(errorMessage: e.toString(), isLoading: false));
      }
    });

    on<EventBlocEventDelete>((event, emit) async {
      if (state is EventStateLoaded) {
        emit((state as EventStateLoaded).copyWith(isLoading: true));
      }

      try {
        await _service.deleteEvent(eventId: event.eventId);

        if (state is EventStateLoaded) {
          emit((state as EventStateLoaded).copyWith(isLoading: false));
        }
      } catch (e) {
        emit(EventBlocStateError(errorMessage: e.toString(), isLoading: false));
      }
    });

    on<EventBlocEventStatusChange>((event, emit) async {
      if (state is EventStateLoaded) {
        emit((state as EventStateLoaded).copyWith(isLoading: true));
      }

      try {
        await EventService().toggleEventActiveStatus(
          eventId: event.eventId,
          isActive: event.isactive,
        );
        if (state is EventStateLoaded) {
          emit((state as EventStateLoaded).copyWith(isLoading: false));
        }
      } catch (e) {
        emit(EventBlocStateError(errorMessage: e.toString(), isLoading: false));
      }
    });

    on<EventBlocEventUpdateTitle>((event, emit) async {
      if (state is EventStateLoaded) {
        emit((state as EventStateLoaded).copyWith(isLoading: true));
      }
      try {
        await _service.updateEvent(
          eventId: event.eventId,
          eventName: event.newName,
        );
        if (state is EventStateLoaded) {
          emit((state as EventStateLoaded).copyWith(isLoading: false));
        }
      } catch (e) {
        emit(EventBlocStateError(errorMessage: e.toString(), isLoading: false));
      }
    });

    on<EventBlocEventReset>((event, emit) {
      _selectedEventId = null;
      emit(const EventStateInitial());
    });
  }
}
