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
    // 1. Fetch Active Events
    on<AttendBlocEventFetchActiveEvents>((event, emit) async {
      emit(const AttendBlocStateLoading());
      try {
        await emit.forEach<List<EventModel>>(
          eventService.getActiveEvents(),
          onData: (events) {
            if (state is AttendBlocStateLoaded) {
              final currentState = state as AttendBlocStateLoaded;
              return AttendBlocStateLoaded(
                eventId: currentState.eventId,
                activeEvents: events,
                attendanceList: currentState.attendanceList,
              );
            }
            return AttendBlocStateInitial(activeEvents: events);
          },
          onError: (error, stackTrace) =>
              AttendBlocStateError(errorMessage: error.toString()),
        );
      } catch (e) {
        emit(AttendBlocStateError(errorMessage: e.toString()));
      }
    });

    // 2. Fetch Attendance (Stream)
    on<AttendBlocEventFetchAttendance>((event, emit) async {
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

    // 3. Batch Submit Logic
    on<AttendBlocEventSubmitBatch>((event, emit) async {
      // Temporarily store current data to restore state if submission fails
      final previousState = state;

      emit(const AttendBlocStateSubmitting());
      try {
        await attendService.submitBatchAttendance(
          eventId: event.eventId,
          updates: event.attendanceUpdates,
        );
        emit(const AttendBlocStateSuccess("Attendance updated successfully!"));

        // After showing success, we can return to the previous state to keep the UI interactive
        if (previousState is AttendBlocStateLoaded) {
          emit(previousState);
        }
      } catch (e) {
        emit(
          AttendBlocStateError(
            errorMessage: "Batch Update Failed: ${e.toString()}",
          ),
        );
      }
    });

    // 4. Reset
    on<AttendBlocEventReset>((event, emit) {
      emit(AttendBlocStateInitial(activeEvents: []));
    });
  }
}
