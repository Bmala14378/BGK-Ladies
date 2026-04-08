import 'package:flutter/material.dart';

@immutable
abstract class BlocState {
  final bool isLoading;
  final String? loadingMessage;
  const BlocState({
    required this.isLoading,
    this.loadingMessage = "Please wait a moment",
  });
}

class BlocStateUninitialized extends BlocState {
  const BlocStateUninitialized({
    required super.isLoading,
  });
}

class BlocStateLoggedIn extends BlocState {
  final int itsNumber;
  const BlocStateLoggedIn({
    required super.isLoading,
    required this.itsNumber,
  });
}

class BlocStateLoggedOut extends BlocState {
  final Exception? exception;
  const BlocStateLoggedOut({
    required super.isLoading,
    required this.exception,
    super.loadingMessage,
  });
}

class BlocStateRegistering extends BlocState {
  final Exception? exception;
  const BlocStateRegistering({
    required this.exception,
    required super.isLoading,
  });
}

class BlocStateNavigatingToLogin extends BlocState {
  const BlocStateNavigatingToLogin({
    required super.isLoading,
  });
}

class BlocStateNavigatingToRegister extends BlocState {
  const BlocStateNavigatingToRegister({
    required super.isLoading,
  });
}
