import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:flutter/material.dart';

@immutable
abstract class AppointBlocEvent {
  const AppointBlocEvent();
}

class AppointBlocEventFetchActiveEvents extends AppointBlocEvent {
  const AppointBlocEventFetchActiveEvents();
}

class AppointBlocEventSelectEvent extends AppointBlocEvent {
  final String eventId;
  const AppointBlocEventSelectEvent({required this.eventId});
}

class AppointBlocEventSubmitAppointment extends AppointBlocEvent {
  final String eventId;
  final List<AttendanceModel> selectedMembers;
  const AppointBlocEventSubmitAppointment({
    required this.eventId,
    required this.selectedMembers,
  });
}

class AppointBlocEventReset extends AppointBlocEvent {
  const AppointBlocEventReset();
}
