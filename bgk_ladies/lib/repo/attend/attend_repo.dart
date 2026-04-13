import 'package:bgk_ladies/constants/vars.dart';
import 'package:bgk_ladies/enums/markaz_enum.dart';
import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<AttendanceModel>> getAttendanceStream({
    required String eventId,
    required MarkazEnum markaz,
  }) {
    try {
      return _db
          .collection(Vars.eventCollection_Var)
          .doc(eventId)
          .collection(Vars.attendanceCollection_Var)
          .where(Vars.markaz_Var, isEqualTo: markaz.name)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => AttendanceModel.fromMap(doc.data()))
                .toList();
          });
    } catch (e) {
      throw Exception("Failed to fetch attendance stream: $e");
    }
  }

  Future<void> updateStatus({
    required String eventId,
    required String itsNumber,
    required StatusEnum status,
  }) async {
    try {
      await _db
          .collection(Vars.eventCollection_Var)
          .doc(eventId)
          .collection(Vars.attendanceCollection_Var)
          .doc(itsNumber)
          .update({
            Vars.status_Var: status.name,
            Vars.dateTime_Var: FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception("Failed to update attendance status: $e");
    }
  }
}
