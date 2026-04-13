import 'package:bgk_ladies/bloc/attend/attend_bloc_events.dart';
import 'package:bgk_ladies/bloc/attend/attend_bloc_states.dart';
import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:bgk_ladies/models/event_model.dart';
import 'package:bgk_ladies/services/attend/attend_service.dart';
import 'package:bgk_ladies/services/event/event_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendBloc extends Bloc<AttendBlocEvent, AttendBlocState> {
  AttendBloc(AttendService attendService, EventService eventService)
    : super(AttendBlocStateInitial(activeEvents: [])) {
    on<AttendBlocEventFetchActiveEvents>((event, emit) async {
      emit(const AttendBlocStateLoading());
      try {
        await emit.forEach<List<EventModel>>(
          eventService.getActiveEvents(),
          onData: (events) {
            // If an event is already selected, keep the user in the Loaded state
            if (state is AttendBlocStateLoaded) {
              final currentState = state as AttendBlocStateLoaded;
              return AttendBlocStateLoaded(
                eventId: currentState.eventId,
                activeEvents: events,
                attendanceList: currentState.attendanceList,
              );
            }
            // Otherwise, stay in the initial state with the new dropdown list
            return AttendBlocStateInitial(activeEvents: events);
          },
          onError: (error, stackTrace) =>
              AttendBlocStateError(errorMessage: error.toString()),
        );
      } catch (e) {
        emit(AttendBlocStateError(errorMessage: e.toString()));
      }
    });

    // 2. Fetch Members when Event is Selected
    on<AttendBlocEventFetchAttendance>((event, emit) async {
      // Grab current events so the dropdown doesn't disappear during loading
      List<EventModel> currentEvents = [];
      if (state is AttendBlocStateInitial) {
        currentEvents = (state as AttendBlocStateInitial).activeEvents;
      } else if (state is AttendBlocStateLoaded) {
        currentEvents = (state as AttendBlocStateLoaded).activeEvents;
      }

      emit(
        AttendBlocStateLoading(
          activeEvents: currentEvents,
          eventId: event.eventId,
        ),
      );

      try {
        await emit.forEach<List<AttendanceModel>>(
          attendService.getMarkazAttendance(event.eventId, event.markaz),
          onData: (attendanceList) => AttendBlocStateLoaded(
            eventId: event.eventId,
            activeEvents: currentEvents,
            attendanceList: attendanceList,
          ),
          onError: (error, stackTrace) =>
              AttendBlocStateError(errorMessage: error.toString()),
        );
      } catch (e) {
        emit(AttendBlocStateError(errorMessage: e.toString()));
      }
    });

    // 3. Update Status
    on<AttendBlocEventUpdateStatus>((event, emit) async {
      try {
        await attendService.submitAttendance(
          eventId: event.eventId,
          itsNumbers: event.itsNumber,
          status: event.status,
        );

      } catch (e) {
        emit(AttendBlocStateError(errorMessage: e.toString()));
      }
    });

    on<AttendBlocEventReset>((event, emit) {
      emit(const AttendBlocStateInitial(activeEvents: []));
    });
  }
}
