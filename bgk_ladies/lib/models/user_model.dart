import 'package:bgk_ladies/constants/vars.dart';
import 'package:bgk_ladies/enums/markaz_enum.dart';
import 'package:bgk_ladies/enums/user_role_enum.dart';

class UserModel {
  final int itsNumber;
  final String passwordHash;
  final UserRoleEnum role;
  final MarkazEnum? markaz;

  UserModel({
    required this.itsNumber,
    required this.passwordHash,
    required this.role,
    required this.markaz,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      itsNumber: map[Vars.itsNo_Var] ?? "",
      passwordHash: map[Vars.passwordHash_Var] ?? "",
      role: UserRoleEnum.values.byName(map[Vars.role_Var] ?? ""),
      markaz: map[Vars.markaz_Var] != null
          ? MarkazEnum.values.byName(map[Vars.markaz_Var])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Vars.itsNo_Var: itsNumber,
      Vars.passwordHash_Var: passwordHash,
      Vars.role_Var: role.name,
      Vars.markaz_Var: markaz?.name,
    };
  }

  bool get canCreateUser =>
      role == UserRoleEnum.superUser ||
      role == UserRoleEnum.officer ||
      role == UserRoleEnum.headAdmin;

  bool get canAppoint =>
      role == UserRoleEnum.superUser ||
      role == UserRoleEnum.officer ||
      role == UserRoleEnum.groupleader;

  bool get canMarkAttendance =>
      role == UserRoleEnum.superUser ||
      role == UserRoleEnum.officer ||
      role == UserRoleEnum.onGroundAdmin;

  bool get canViewReports =>
      role == UserRoleEnum.superUser ||
      role == UserRoleEnum.officer ||
      role == UserRoleEnum.headAdmin ||
      role == UserRoleEnum.captain ||
      role == UserRoleEnum.groupleader;

  bool get canManageEvents =>
      role == UserRoleEnum.superUser ||
      role == UserRoleEnum.officer ||
      role == UserRoleEnum.headAdmin;
}
