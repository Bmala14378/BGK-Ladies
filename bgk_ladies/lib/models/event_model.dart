import 'package:bgk_ladies/constants/vars.dart';

class EventModel {
  final String eventId;
  final String eventName;
  final bool isactive;

  EventModel({
    required this.eventId,
    required this.eventName,
    this.isactive = true,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      eventId: map[Vars.eventId_Var] ?? "",
      eventName: map[Vars.eventName_Var] ?? "",
      isactive: map[Vars.isactive_Var] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Vars.eventId_Var: eventId,
      Vars.eventName_Var: eventName,
      Vars.isactive_Var: isactive,
    };
  }
}
