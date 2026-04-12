import 'package:bgk_ladies/constants/vars.dart';

class MemberModel {
  final String itsNumber;
  final String name;
  final String glName;
  final String mohalla;
  final String markaz;
  final String remarks;

  MemberModel({
    required this.itsNumber,
    required this.name,
    required this.glName,
    required this.mohalla,
    required this.markaz,
    required this.remarks,
  });

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      itsNumber: map[Vars.itsNo_Var] ?? 0,
      name: map[Vars.name_Var] ?? "",
      glName: map[Vars.glName_Var] ?? "",
      mohalla: map[Vars.mohalla_Var] ?? "",
      markaz: map[Vars.markaz_Var] ?? "",
      remarks: map[Vars.remarks_Var] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Vars.itsNo_Var: itsNumber,
      Vars.name_Var: name,
      Vars.glName_Var: glName,
      Vars.mohalla_Var: mohalla,
      Vars.markaz_Var: markaz,
      Vars.remarks_Var: remarks,
    };
  }
}
