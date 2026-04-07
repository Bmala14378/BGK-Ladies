import 'package:bgk_ladies/constants/vars.dart';
import 'package:bgk_ladies/enums/status_enum.dart';

class AttendanceModel {
  final String eventId;
  final DateTime dateTime;
  final int itsNumber;
  final String name;
  final StatusEnum status;

  AttendanceModel({
    required this.eventId,
    required this.dateTime,
    required this.itsNumber,
    required this.name,
    required this.status,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      eventId: map[Vars.eventId_Var] ?? "",
      dateTime: DateTime.parse(
        map[Vars.dateTime_Var] ?? DateTime.now().toIso8601String(),
      ),
      itsNumber: map[Vars.itsNo_Var] ?? 0,
      name: map[Vars.name_Var] ?? "",
      status: StatusEnum.values.byName(map[Vars.status_Var] ?? "na"),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Vars.eventId_Var: eventId,
      Vars.dateTime_Var: dateTime.toIso8601String(),
      Vars.itsNo_Var: itsNumber,
      Vars.name_Var: name,
      Vars.status_Var: status.name,
    };
  }

  bool get isLocked =>
      status == StatusEnum.present ||
      status == StatusEnum.absent ||
      status == StatusEnum.late;
}
