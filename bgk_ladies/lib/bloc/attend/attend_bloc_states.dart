import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:bgk_ladies/models/event_model.dart';
import 'package:flutter/material.dart';

@immutable
abstract class AttendBlocState {
  const AttendBlocState();
}

class AttendBlocStateInitial extends AttendBlocState {
  final List<EventModel> activeEvents;
  const AttendBlocStateInitial({required this.activeEvents});
}

class AttendBlocStateLoading extends AttendBlocState {
  final List<EventModel>? activeEvents;
  final String? eventId;
  const AttendBlocStateLoading({this.activeEvents, this.eventId});
}

class AttendBlocStateLoaded extends AttendBlocState {
  final String eventId;
  final List<EventModel> activeEvents;
  final List<AttendanceModel> attendanceList;

  const AttendBlocStateLoaded({
    required this.eventId,
    required this.activeEvents,
    required this.attendanceList,
  });
}

// NEW: Submission States
class AttendBlocStateSubmitting extends AttendBlocState {
  const AttendBlocStateSubmitting();
}

class AttendBlocStateSuccess extends AttendBlocState {
  final String message;
  const AttendBlocStateSuccess(this.message);
}

class AttendBlocStateError extends AttendBlocState {
  final String errorMessage;
  const AttendBlocStateError({required this.errorMessage});
}
