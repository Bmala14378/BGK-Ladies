import 'package:bgk_ladies/models/event_model.dart';
import 'package:flutter/material.dart';

@immutable
abstract class AppointBlocState {
  const AppointBlocState();
}

class AppointBlocStateInitial extends AppointBlocState {
  final List<EventModel> activeEvents;
  const AppointBlocStateInitial({required this.activeEvents});
}

class AppointBlocStateLoading extends AppointBlocState {
  const AppointBlocStateLoading();
}

class AppointBlocStateAppointmentSubmitted extends AppointBlocState {
  const AppointBlocStateAppointmentSubmitted();
}

class AppointBlocStateError extends AppointBlocState {
  final String errorMessage;
const AppointBlocStateError({required this.errorMessage});
}

class AppointBlocStateEventSelected extends AppointBlocState {
  final String eventId;
  final List<EventModel> activeEvents;
  final List<String> appointedItsNumbers; // Added this field

  const AppointBlocStateEventSelected({
    required this.eventId,
    required this.activeEvents,
    required this.appointedItsNumbers,
  });
}
