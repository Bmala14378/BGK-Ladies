import 'package:bgk_ladies/enums/markaz_enum.dart';
import 'package:bgk_ladies/enums/user_role_enum.dart';
import 'package:flutter/material.dart';

@immutable
abstract class AuthBlocEvent {
  const AuthBlocEvent();
}

class AuthBlocEventInitialize extends AuthBlocEvent {
  const AuthBlocEventInitialize();
}

class AuthBlocEventLogIn extends AuthBlocEvent {
  final int itsNumber;
  final String password;

  const AuthBlocEventLogIn({required this.itsNumber, required this.password});
}

class AuthBlocEventNavigateToLogin extends AuthBlocEvent {
  const AuthBlocEventNavigateToLogin();
}

class AuthBlocEventLogOut extends AuthBlocEvent {
  const AuthBlocEventLogOut();
}

class AuthBlocEventRegister extends AuthBlocEvent {
  final int itsNumber;
  final UserRoleEnum role;
  final MarkazEnum? markaz;
  final String password;

  const AuthBlocEventRegister({
    required this.itsNumber,
    required this.password,
    required this.role,
    required this.markaz,
  });
}

class AuthBlocEventNavigateToRegister extends AuthBlocEvent {
  const AuthBlocEventNavigateToRegister();
}

class AuthBlocEventNavigateToDash extends AuthBlocEvent {
  const AuthBlocEventNavigateToDash();
}
