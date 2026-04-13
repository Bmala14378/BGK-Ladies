import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:bgk_ladies/models/event_model.dart';
import 'package:flutter/material.dart';

@immutable
abstract class AttendBlocState {
  const AttendBlocState();
}

// 1. Initial State: Has events, but no event is selected yet
class AttendBlocStateInitial extends AttendBlocState {
  final List<EventModel> activeEvents;
  const AttendBlocStateInitial({required this.activeEvents});
}

// 2. Loading State: Can hold activeEvents so the dropdown doesn't vanish while loading members
class AttendBlocStateLoading extends AttendBlocState {
  final List<EventModel>? activeEvents;
  final String? eventId;
  const AttendBlocStateLoading({this.activeEvents, this.eventId});
}

// 3. Loaded State: Holds the events for the dropdown, the selected ID, and the attendance list
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

class AttendBlocStateError extends AttendBlocState {
  final String errorMessage;
  const AttendBlocStateError({required this.errorMessage});
}
