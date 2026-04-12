import 'package:bgk_ladies/constants/vars.dart';
import 'package:bgk_ladies/enums/status_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final DateTime dateTime;
  final String itsNumber;
  final String name;
  final String glName;
  final String mohalla;
  final String markaz;
  final StatusEnum status;

  AttendanceModel({
    required this.dateTime,
    required this.itsNumber,
    required this.name,
    required this.status,
    required this.glName,
    required this.mohalla,
    required this.markaz,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate = DateTime.now();
    var dateValue = map[Vars.dateTime_Var];

    if (dateValue is Timestamp) {
      parsedDate = dateValue
          .toDate(); 
    } else if (dateValue is String) {
      parsedDate = DateTime.parse(dateValue);
    }

    return AttendanceModel(
      dateTime: parsedDate,
      itsNumber: map[Vars.itsNo_Var] ?? 0,
      name: map[Vars.name_Var] ?? "",
      status: StatusEnum.values.byName(map[Vars.status_Var] ?? "na"),
      glName: map[Vars.glName_Var] ?? "",
      mohalla: map[Vars.mohalla_Var] ?? "",
      markaz: map[Vars.markaz_Var] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Vars.dateTime_Var: dateTime.toIso8601String(),
      Vars.itsNo_Var: itsNumber,
      Vars.name_Var: name,
      Vars.glName_Var: glName,
      Vars.mohalla_Var: mohalla,
      Vars.markaz_Var: markaz,
      Vars.status_Var: status.name,
    };
  }

  bool get isLocked =>
      status == StatusEnum.present ||
      status == StatusEnum.absent ||
      status == StatusEnum.late;
}
