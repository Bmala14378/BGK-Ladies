import 'package:bgk_ladies/enums/markaz_enum.dart';
import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:bgk_ladies/repo/attend/attend_repo.dart';

class AttendService {
  final _repo = AttendRepository();

  Stream<List<AttendanceModel>> getEventAttendance({required String eventId}) {
    return _repo.getFullAttendanceStream(eventId: eventId);
  }

  Stream<List<AttendanceModel>> getMarkazAttendance(
    String eventId,
    MarkazEnum markaz,
  ) {
    return _repo.getAttendanceStream(eventId: eventId, markaz: markaz);
  }

  Future<void> submitAttendance({
    required String eventId,
    required String itsNumbers,
    required StatusEnum status,
  }) async {
    await _repo.updateStatus(
      eventId: eventId,
      itsNumber: itsNumbers,
      status: status,
    );
  }

  Future<void> submitBatchAttendance({
    required String eventId,
    required Map<String, StatusEnum> updates,
  }) async {
    await _repo.submitBatchAttendance(eventId: eventId, updates: updates);
  }

  /// Fetches the attendance history of a single member across the supplied
  /// [allEventIds] using direct document reads (no Firestore index needed).
  Future<List<AttendanceModel>> getMemberHistory({
    required String itsNumber,
    required List<String> allEventIds,
  }) async {
    return await _repo.getMemberHistory(
      itsNumber: itsNumber,
      allEventIds: allEventIds,
    );
  }
}
