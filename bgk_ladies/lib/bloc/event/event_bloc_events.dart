import 'package:bgk_ladies/models/event_model.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class EventBlocEvent {
  const EventBlocEvent();
}

class EventBlocEventInitialize extends EventBlocEvent {
  const EventBlocEventInitialize();
}

class EventBlocEventUpdateList extends EventBlocEvent {
  final List<EventModel> allEvents;
  const EventBlocEventUpdateList(this.allEvents);
}

class EventBlocEventSelectEvent extends EventBlocEvent {
  final String eventId;
  const EventBlocEventSelectEvent(this.eventId);
}

class EventBlocEventUpdateTitle extends EventBlocEvent {
  final String eventId;
  final String newName;
  const EventBlocEventUpdateTitle({
    required this.eventId,
    required this.newName,
  });
}

class EventBlocEventReset extends EventBlocEvent {
  const EventBlocEventReset();
}
