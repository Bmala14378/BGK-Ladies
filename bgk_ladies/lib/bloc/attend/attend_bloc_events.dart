import 'package:bgk_ladies/enums/markaz_enum.dart';
import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:flutter/material.dart';

@immutable
abstract class AttendBlocEvent {
  const AttendBlocEvent();
}

// 1. Fire this when the Bloc is created (populates the dropdown)
class AttendBlocEventFetchActiveEvents extends AttendBlocEvent {
  const AttendBlocEventFetchActiveEvents();
}

// 2. Fire this when the user selects an event from the dropdown
class AttendBlocEventFetchAttendance extends AttendBlocEvent {
  final String eventId;
  final MarkazEnum markaz; // The admin's markaz
  const AttendBlocEventFetchAttendance({required this.eventId, required this.markaz});
}

// 3. Fire this when the admin taps present/late/absent
class AttendBlocEventUpdateStatus extends AttendBlocEvent {
  final String eventId;
  final String itsNumber;
  final StatusEnum status;
  const AttendBlocEventUpdateStatus({
    required this.eventId,
    required this.itsNumber,
    required this.status,
  });
}

class AttendBlocEventReset extends AttendBlocEvent {
  const AttendBlocEventReset();
}