import 'dart:developer' as devtools;

import 'package:bgk_ladies/bloc/auth/auth_bloc_event.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_states.dart';
import 'package:bgk_ladies/models/user_model.dart';
import 'package:bgk_ladies/repo/auth/auth_repo.dart';
import 'package:bgk_ladies/utilites/hash_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBlocFunc extends Bloc<AuthBlocEvent, AuthBlocState> {
  AuthBlocFunc(AuthRepository repo)
    : super(const AuthBlocStateUninitialized(isLoading: true)) {
    on<AuthBlocEventInitialize>((event, emit) async {
      final user = await repo.getCurrentUser();
      if (user == null) {
        emit(const AuthBlocStateLoggedOut(isLoading: false, exception: null));
      } else {
        emit(
          AuthBlocStateLoggedIn(
            isLoading: false,
            itsNumber: user.itsNumber,
            user: user,
          ),
        );
      }
    });

    on<AuthBlocEventLogIn>((event, emit) async {
      emit(
        const AuthBlocStateLoggedOut(
          isLoading: true,
          exception: null,
          loadingMessage: "Logging in...",
        ),
      );
      try {
        final user = await repo.login(
          itsNumber: event.itsNumber,
          password: event.password,
        );
        devtools.log("user logged in");
        emit(
          AuthBlocStateLoggedIn(
            isLoading: false,
            itsNumber: user!.itsNumber,
            user: user,
          ),
        );
      } on Exception catch (e) {
        emit(AuthBlocStateLoggedOut(isLoading: false, exception: e));
      }
    });

    on<AuthBlocEventLogOut>((event, emit) async {
      await repo.logOut();
      emit(const AuthBlocStateLoggedOut(isLoading: false, exception: null));
    });

    on<AuthBlocEventRegister>((event, emit) async {
      emit(const AuthBlocStateRegistering(isLoading: true, exception: null));
      try {
        await repo.register(
          UserModel(
            itsNumber: event.itsNumber,
            passwordHash: hashPassword(event.password),
            role: event.role,
            markaz: event.markaz,
          ),
        );
        emit(const AuthBlocRegistered(isLoading: false));
      } on Exception catch (e) {
        emit(AuthBlocStateRegistering(isLoading: false, exception: e));
      }
    });

    on<AuthBlocEventNavigateToLogin>((event, emit) {
      emit(AuthBlocStateNavigatingToLogin(isLoading: false));
    });

    on<AuthBlocEventNavigateToRegister>((event, emit) {
      emit(AuthBlocStateNavigatingToRegister(isLoading: false));
    });

    on<AuthBlocEventNavigateToDash>((event, emit) {
      emit(AuthBlocStatesNavigatingToDash(isLoading: false, user: event.user));
    });
  }
}
