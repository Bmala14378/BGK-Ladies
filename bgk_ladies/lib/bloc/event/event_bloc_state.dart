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

  EventStateLoaded copyWith({bool? isLoading}) {
    return EventStateLoaded(
      activeEvents: activeEvents,
      allEvents: allEvents,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class EventStateCurrentEventDisabled extends EventBlocState {
  final String message;
  const EventStateCurrentEventDisabled(this.message) : super(isLoading: false);
}

class EventBlocStateError extends EventBlocState {
  final String errorMessage;
  const EventBlocStateError({
    required this.errorMessage,
    required super.isLoading,
  });
}