import 'package:bgk_ladies/bloc/appoint/appoint_bloc_event.dart';
import 'package:bgk_ladies/bloc/appoint/appoint_bloc_state.dart';
import 'package:bgk_ladies/models/event_model.dart';
import 'package:bgk_ladies/services/appoint/appoint_service.dart';
import 'package:bgk_ladies/services/event/event_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppointBloc extends Bloc<AppointBlocEvent, AppointBlocState> {
  AppointBloc(AppointService appointService, EventService eventService)
    : super(AppointBlocStateInitial(activeEvents: [])) {
    // 1. Update the FetchActiveEvents handler
    on<AppointBlocEventFetchActiveEvents>((event, emit) async {
      emit(const AppointBlocStateLoading());
      try {
        await emit.forEach<List<EventModel>>(
          eventService.getActiveEvents(),
          onData: (events) {
            if (state is AppointBlocStateEventSelected) {
              final currentState = state as AppointBlocStateEventSelected;
              return AppointBlocStateEventSelected(
                eventId: currentState.eventId,
                activeEvents: events,
                appointedItsNumbers:
                    currentState.appointedItsNumbers, // Add this
              );
            }
            return AppointBlocStateInitial(activeEvents: events);
          },
          onError: (error, stackTrace) =>
              AppointBlocStateError(errorMessage: error.toString()),
        );
      } catch (e) {
        emit(AppointBlocStateError(errorMessage: e.toString()));
      }
    });

    // 2. Update the SelectEvent handler (using the stream approach suggested earlier)
    on<AppointBlocEventSelectEvent>((event, emit) async {
      List<EventModel> currentEvents = [];
      if (state is AppointBlocStateInitial) {
        currentEvents = (state as AppointBlocStateInitial).activeEvents;
      } else if (state is AppointBlocStateEventSelected) {
        currentEvents = (state as AppointBlocStateEventSelected).activeEvents;
      }

      // Use emit.forEach to fetch the data and fill the required parameter
      await emit.forEach<List<String>>(
        appointService.getAppointedItsNumbers(event.eventId),
        onData: (appointedIts) => AppointBlocStateEventSelected(
          eventId: event.eventId,
          activeEvents: currentEvents,
          appointedItsNumbers: appointedIts, // Now the requirement is met
        ),
        onError: (error, stackTrace) =>
            AppointBlocStateError(errorMessage: error.toString()),
      );
    });

    on<AppointBlocEventSubmitAppointment>((event, emit) async {
      emit(AppointBlocStateLoading());
      try {
        await appointService.appointMembers(
          eventId: event.eventId,
          selectedMembers: event.selectedMembers,
        );
        emit(AppointBlocStateAppointmentSubmitted());
      } catch (e) {
        emit(AppointBlocStateError(errorMessage: e.toString()));
      }
    });

    on<AppointBlocEventReset>((event, emit) {
      emit(AppointBlocStateInitial(activeEvents: []));
    });
  }
}
