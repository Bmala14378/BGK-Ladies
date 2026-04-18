import 'package:bgk_ladies/models/attendance_model.dart';
import 'package:bgk_ladies/repo/appoint/appoint_repo.dart';

class AppointService {
  final repo = AppointRepository();

  Future<void> appointMembers({
    required String eventId,
    required List<AttendanceModel> selectedMembers,
  }) async {
    await repo.appointMember(
      eventId: eventId,
      selectedMembers: selectedMembers,
    );
  }

  Stream<List<String>> getAppointedItsNumbers(String eventId) {
    return repo.getAppointedItsNumbersStream(eventId);
  }
}
