import 'package:bgk_ladies/constants/vars.dart';
import 'package:bgk_ladies/enums/markaz_enum.dart';
import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendRepository {
  final _db = FirebaseFirestore.instance;

  // ── Streams ───────────────────────────────────────────────────────────────

  Stream<List<AttendanceModel>> getFullAttendanceStream({
    required String eventId,
  }) {
    try {
      return _db
          .collection(Vars.eventCollection_Var)
          .doc(eventId)
          .collection(Vars.attendanceCollection_Var)
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

  // ── Writes ────────────────────────────────────────────────────────────────

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
          .set({Vars.status_Var: status.name}, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Failed to update status: $e");
    }
  }

  Future<void> submitBatchAttendance({
    required String eventId,
    required Map<String, StatusEnum> updates,
  }) async {
    try {
      final batch = _db.batch();
      final collectionRef = _db
          .collection(Vars.eventCollection_Var)
          .doc(eventId)
          .collection(Vars.attendanceCollection_Var);

      updates.forEach((itsNumber, status) {
        final docRef = collectionRef.doc(itsNumber);
        batch.set(docRef, {
          Vars.status_Var: status.name,
          Vars.dateTime_Var: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      await batch.commit();
    } catch (e) {
      throw Exception("Failed to commit batch attendance: $e");
    }
  }

  // ── Cross-event member history ─────────────────────────────────────────────

  /// Fetches all attendance records for a single member across the supplied
  /// [allEventIds] using direct document reads — no Firestore index required.
  ///
  /// Each attendance document uses the ITS number as its document ID, so we
  /// can read `Events/{eventId}/Attendance/{itsNumber}` directly for every
  /// event and filter out documents that don't exist (member wasn't appointed).
  Future<List<AttendanceModel>> getMemberHistory({
    required String itsNumber,
    required List<String> allEventIds,
  }) async {
    if (allEventIds.isEmpty) return [];
    try {
      final futures = allEventIds.map(
        (eventId) => _db
            .collection(Vars.eventCollection_Var)
            .doc(eventId)
            .collection(Vars.attendanceCollection_Var)
            .doc(itsNumber)
            .get(),
      );
      final docs = await Future.wait(futures);
      // Zip docs with their eventIds — Future.wait preserves insertion order.
      final results = <AttendanceModel>[];
      for (int i = 0; i < docs.length; i++) {
        if (docs[i].exists) {
          results.add(
            AttendanceModel.fromMap(docs[i].data()!, eventId: allEventIds[i]),
          );
        }
      }
      return results;
    } catch (e) {
      throw Exception("Failed to fetch member history: $e");
    }
  }
}
