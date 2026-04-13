import 'package:bgk_ladies/enums/markaz_enum.dart';
import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:flutter/material.dart';

@immutable
abstract class AttendBlocEvent {
  const AttendBlocEvent();
}

class AttendBlocEventFetchActiveEvents extends AttendBlocEvent {
  const AttendBlocEventFetchActiveEvents();
}

class AttendBlocEventFetchAttendance extends AttendBlocEvent {
  final String eventId;
  final MarkazEnum markaz;
  const AttendBlocEventFetchAttendance({
    required this.eventId,
    required this.markaz,
  });
}

// Keeping this for potential single-row corrections
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

// NEW: Batch Submit Event
class AttendBlocEventSubmitBatch extends AttendBlocEvent {
  final String eventId;
  final Map<String, StatusEnum> attendanceUpdates;
  const AttendBlocEventSubmitBatch({
    required this.eventId,
    required this.attendanceUpdates,
  });
}

class AttendBlocEventReset extends AttendBlocEvent {
  const AttendBlocEventReset();
}
