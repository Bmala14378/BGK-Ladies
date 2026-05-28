import 'package:bgk_ladies/constants/vars.dart';
import 'package:bgk_ladies/enums/markaz_enum.dart';

class MemberModel {
  final String itsNumber;
  final String name;
  final String glName;
  final String mohalla;
  final MarkazEnum markaz;
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
      markaz: MarkazEnum.values.byName(map[Vars.markaz_Var]),
      remarks: map[Vars.remarks_Var] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Vars.itsNo_Var: itsNumber,
      Vars.name_Var: name,
      Vars.glName_Var: glName,
      Vars.mohalla_Var: mohalla,
      Vars.markaz_Var: markaz.name, // store as string, not enum object
      Vars.remarks_Var: remarks,
    };
  }
}
