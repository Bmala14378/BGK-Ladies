import 'package:bgk_ladies/models/user_model.dart';
import 'package:flutter/material.dart';

@immutable
abstract class AuthBlocState {
  final bool isLoading;
  final String? loadingMessage;
  const AuthBlocState({
    required this.isLoading,
    this.loadingMessage = "Please wait a moment",
  });
}

class AuthBlocStateUninitialized extends AuthBlocState {
  const AuthBlocStateUninitialized({required super.isLoading});
}

class AuthBlocStateLoggedIn extends AuthBlocState {
  final int itsNumber;
  final UserModel user;
  const AuthBlocStateLoggedIn({
    required super.isLoading,
    required this.itsNumber,
    required this.user,
  });
}

class AuthBlocStateLoggedOut extends AuthBlocState {
  final Exception? exception;
  const AuthBlocStateLoggedOut({
    required super.isLoading,
    required this.exception,
    super.loadingMessage,
  });
}

class AuthBlocStateRegistering extends AuthBlocState {
  final Exception? exception;
  const AuthBlocStateRegistering({
    required this.exception,
    required super.isLoading,
  });
}

class AuthBlocRegistered extends AuthBlocState {
  const AuthBlocRegistered({required super.isLoading});
}

class AuthBlocStateNavigatingToLogin extends AuthBlocState {
  const AuthBlocStateNavigatingToLogin({required super.isLoading});
}

class AuthBlocStateNavigatingToRegister extends AuthBlocState {
  const AuthBlocStateNavigatingToRegister({required super.isLoading});
}

class AuthBlocStatesNavigatingToDash extends AuthBlocState {
  const AuthBlocStatesNavigatingToDash({required super.isLoading});
}
