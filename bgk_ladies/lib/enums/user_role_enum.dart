enum UserRoleEnum {
  superUser,
  officer,
  headAdmin,
  captain,
  groupleader,
  onGroundAdmin,
}

extension UserRoleExtension on UserRoleEnum {
  String get displayName {
    switch (this) {
      case UserRoleEnum.superUser:
        return 'Super User';
      case UserRoleEnum.officer:
        return 'Officer';
      case UserRoleEnum.headAdmin:
        return 'Head Admin';
      case UserRoleEnum.captain:
        return 'Captain';
      case UserRoleEnum.groupleader:
        return 'Group Leader';
      case UserRoleEnum.onGroundAdmin:
        return 'On-Ground Admin';
    }
  }
}
