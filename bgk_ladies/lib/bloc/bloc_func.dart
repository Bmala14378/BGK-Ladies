import 'dart:developer' as devtools;

import 'package:bgk_ladies/bloc/bloc_event.dart';
import 'package:bgk_ladies/bloc/bloc_states.dart';
import 'package:bgk_ladies/models/user_model.dart';
import 'package:bgk_ladies/repo/auth_repo.dart';
import 'package:bgk_ladies/utilites/hash_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocFunc extends Bloc<BlocEvent, BlocState> {
  BlocFunc(AuthRepository repo)
    : super(const BlocStateUninitialized(isLoading: true)) {
    on<BlocEventInitialize>((event, emit) async {
      final user = await repo.getCurrentUser();
      if (user == null) {
        emit(const BlocStateLoggedOut(isLoading: false, exception: null));
      } else {
        emit(BlocStateLoggedIn(isLoading: false, itsNumber: user.itsNumber));
      }
    });

    on<BlocEventLogIn>((event, emit) async {
      emit(
        const BlocStateLoggedOut(
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
        emit(BlocStateLoggedIn(isLoading: false, itsNumber: user!.itsNumber));
      } on Exception catch (e) {
        emit(BlocStateLoggedOut(isLoading: false, exception: e));
      }
    });

    on<BlocEventLogOut>((event, emit) async {
      await repo.logOut();
      emit(const BlocStateLoggedOut(isLoading: false, exception: null));
    });

    on<BlocEventRegister>((event, emit) async {
      emit(const BlocStateRegistering(isLoading: true, exception: null));
      try {
        await repo.register(
          UserModel(
            itsNumber: event.itsNumber,
            passwordHash: hashPassword(event.password),
            role: event.role,
            markaz: event.markaz,
          ),
        );
        emit(const BlocStateLoggedOut(isLoading: false, exception: null));
      } on Exception catch (e) {
        emit(BlocStateRegistering(isLoading: false, exception: e));
      }
    });

    on<BlocEventNavigateToLogin>((event, emit) {
      emit(BlocStateNavigatingToLogin(isLoading: false));
    });

    on<BlocEventNavigateToRegister>((event, emit) {
      emit(BlocStateNavigatingToRegister(isLoading: false));
    });
  }
}
