import 'package:bgk_ladies/enums/markaz_enum.dart';
import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:bgk_ladies/repo/attend/attend_repo.dart';

class AttendService {
  final _repo = AttendRepository();

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
}
