import 'dart:developer' as devtools;

import 'package:bgk_ladies/constants/vars.dart';
import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> appointMember({
    required String eventId,
    required List<AttendanceModel> selectedMembers,
  }) async {
    try {
      final batch = _db.batch();
      final attendanceCollection = _db
          .collection(Vars.eventCollection_Var)
          .doc(eventId)
          .collection(Vars.attendanceCollection_Var);

      for (var member in selectedMembers) {
        final attendanceDoc = attendanceCollection.doc(
          member.itsNumber.toString(),
        );
        batch.set(attendanceDoc, {
          Vars.itsNo_Var: member.itsNumber,
          Vars.name_Var: member.name,
          Vars.glName_Var: member.glName,
          Vars.mohalla_Var: member.mohalla,
          Vars.markaz_Var: member.markaz.name,
          Vars.status_Var: StatusEnum.appointed.name,
          Vars.dateTime_Var: FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      devtools.log(
        "Successfully appointed ${selectedMembers.length} members to event $eventId",
      );
    } catch (e) {
      devtools.log("Error appointing member: $e");
      throw Exception("Failed to appoint member");
    }
  }

  Stream<List<String>> getAppointedItsNumbersStream(String eventId) {
    return _db
        .collection(Vars.eventCollection_Var)
        .doc(eventId)
        .collection(Vars.attendanceCollection_Var)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.id).toList();
        });
  }
}
