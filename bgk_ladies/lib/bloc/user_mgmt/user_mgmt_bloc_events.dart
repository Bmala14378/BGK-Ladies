import 'package:flutter/material.dart';

@immutable
abstract class UserMgmtBlocEvent {
  const UserMgmtBlocEvent();
}

class UserMgmtBlocEventFetch extends UserMgmtBlocEvent {
  const UserMgmtBlocEventFetch();
}

class UserMgmtBlocEventSearch extends UserMgmtBlocEvent {
  final String query;
  const UserMgmtBlocEventSearch({required this.query});
}

class UserMgmtBlocEventResetPassword extends UserMgmtBlocEvent {
  final int itsNumber;
  const UserMgmtBlocEventResetPassword({required this.itsNumber});
}

class UserMgmtBlocEventDeleteUser extends UserMgmtBlocEvent {
  final int itsNumber;
  const UserMgmtBlocEventDeleteUser({required this.itsNumber});
}
