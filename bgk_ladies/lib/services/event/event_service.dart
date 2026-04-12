import 'dart:developer' as devtools;

import 'package:bgk_ladies/constants/vars.dart';
import 'package:bgk_ladies/models/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventService {
  final _eventCollection = FirebaseFirestore.instance.collection(
    Vars.eventCollection_Var,
  );

  Future<void> createEvent({required String eventName}) async {
    await _eventCollection.add({
      Vars.eventId_Var: _eventCollection.doc().id,
      Vars.eventName_Var: eventName,
      Vars.isactive_Var: true,
    });
  }

  Future<void> updateEvent({
    required String eventId,
    required String eventName,
  }) async {
    await _eventCollection.doc(eventId).update({Vars.eventName_Var: eventName});
  }

  Future<void> deleteEvent({required String eventId}) async {
    await _eventCollection.doc(eventId).delete();
  }

  Future<void> toggleEventActiveStatus({
    required String eventId,
    required bool isActive,
  }) async {
    await _eventCollection.doc(eventId).update({Vars.isactive_Var: isActive});
  }

  Stream<List<EventModel>> getAllEvents() {
    return _eventCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<EventModel>> getActiveEvents() {
    devtools.log("Fetching active events stream");
    final activeEvents = _eventCollection
        .where(Vars.isactive_Var, isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return EventModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
    devtools.log("Fetched active events stream $activeEvents");
    return activeEvents;
  }
}
