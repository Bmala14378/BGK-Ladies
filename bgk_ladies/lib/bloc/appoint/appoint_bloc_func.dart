import 'package:bgk_ladies/bloc/appoint/appoint_bloc_event.dart';
import 'package:bgk_ladies/bloc/appoint/appoint_bloc_state.dart';
import 'package:bgk_ladies/models/event_model.dart';
import 'package:bgk_ladies/services/appoint/appoint_service.dart';
import 'package:bgk_ladies/services/event/event_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppointBloc extends Bloc<AppointBlocEvent, AppointBlocState> {
  AppointBloc(AppointService appointService, EventService eventService)
    : super(AppointBlocStateInitial(activeEvents: [])) {
    on<AppointBlocEventFetchActiveEvents>((event, emit) async {
      emit(const AppointBlocStateLoading());

      try {
        await emit.forEach<List<EventModel>>(
          eventService.getActiveEvents(),
          onData: (events) {
            if (state is AppointBlocStateEventSelected) {
              return AppointBlocStateEventSelected(
                eventId: (state as AppointBlocStateEventSelected).eventId,
                activeEvents: events,
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

    on<AppointBlocEventSelectEvent>((event, emit) {
      if (state is AppointBlocStateInitial) {
        emit(
          AppointBlocStateEventSelected(
            eventId: event.eventId,
            activeEvents: (state as AppointBlocStateInitial).activeEvents,
          ),
        );
      } else if (state is AppointBlocStateEventSelected) {
        emit(
          AppointBlocStateEventSelected(
            eventId: event.eventId,
            activeEvents: (state as AppointBlocStateEventSelected).activeEvents,
          ),
        );
      }
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
  }
}
