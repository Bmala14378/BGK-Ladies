import 'package:flutter/foundation.dart';

@immutable
abstract class EventBlocEvent {
  const EventBlocEvent();
}

class EventBlocEventInitialize extends EventBlocEvent {
  const EventBlocEventInitialize();
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

class EventBlocEventCreate extends EventBlocEvent {
  final String eventName;
  const EventBlocEventCreate({required this.eventName});
}

class EventBlocEventDelete extends EventBlocEvent {
  final String eventId;
  const EventBlocEventDelete({required this.eventId});
}

class EventBlocEventStatusChange extends EventBlocEvent {
  final String eventId;
  final bool isactive;
  const EventBlocEventStatusChange({
    required this.eventId,
    required this.isactive,
  });
}
