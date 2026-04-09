import 'package:bgk_ladies/models/event_model.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class EventBlocState {
  final bool isLoading;
  const EventBlocState({required this.isLoading});
}

class EventStateInitial extends EventBlocState {
  const EventStateInitial() : super(isLoading: true);
}

class EventStateLoaded extends EventBlocState {
  final List<EventModel> activeEvents;
  final List<EventModel> allEvents;
  const EventStateLoaded({
    required this.activeEvents,
    required this.allEvents,
    required super.isLoading,
  });
}

class EventStateCurrentEventDisabled extends EventBlocState {
  final String message;
  const EventStateCurrentEventDisabled(this.message) : super(isLoading: false);
}
