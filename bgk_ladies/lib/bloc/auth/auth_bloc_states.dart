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

class AuthBlocRegistered extends AuthBlocState {
  final UserModel? user;
  const AuthBlocRegistered({required super.isLoading, required this.user});
}

class AuthBlocStateNavigatingToLogin extends AuthBlocState {
  const AuthBlocStateNavigatingToLogin({required super.isLoading});
}

class AuthBlocStateNavigatingToRegister extends AuthBlocState {
  final UserModel user;

  const AuthBlocStateNavigatingToRegister({
    required super.isLoading,
    super.loadingMessage,
    required this.user,
  });
}

class AuthBlocStatesNavigatingToDash extends AuthBlocState {
  final UserModel user;
  const AuthBlocStatesNavigatingToDash({
    required super.isLoading,
    required this.user,
  });
}

class AuthBlocStateError extends AuthBlocState {
  final String exception;
  final UserModel? currentUser;

  const AuthBlocStateError({
    required super.isLoading,
    required this.exception,
    required this.currentUser,
  });
}
