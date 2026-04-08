import 'package:bgk_ladies/enums/markaz_enum.dart';
import 'package:bgk_ladies/enums/user_role_enum.dart';
import 'package:flutter/material.dart';

@immutable
abstract class BlocEvent {
  const BlocEvent();
}

class BlocEventInitialize extends BlocEvent {
  const BlocEventInitialize();
}

class BlocEventLogIn extends BlocEvent {
  final int itsNumber;
  final String password;

  const BlocEventLogIn({required this.itsNumber, required this.password});
}

class BlocEventNavigateToLogin extends BlocEvent {
  const BlocEventNavigateToLogin();
}

class BlocEventLogOut extends BlocEvent {
  const BlocEventLogOut();
}

class BlocEventRegister extends BlocEvent {
  final int itsNumber;
  final UserRoleEnum role;
  final MarkazEnum? markaz;
  final String password;

  const BlocEventRegister({
    required this.itsNumber,
    required this.password,
    required this.role,
    required this.markaz,
  });
}

class BlocEventNavigateToRegister extends BlocEvent {
  const BlocEventNavigateToRegister();
}
