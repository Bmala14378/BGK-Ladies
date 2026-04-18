import 'dart:developer' as devtools;

import 'package:bgk_ladies/bloc/auth/auth_bloc_event.dart';
import 'package:bgk_ladies/bloc/auth/auth_bloc_states.dart';
import 'package:bgk_ladies/models/user_model.dart';
import 'package:bgk_ladies/repo/auth/auth_repo.dart';
import 'package:bgk_ladies/services/member/member_service.dart';
import 'package:bgk_ladies/utilites/hash_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBlocFunc extends Bloc<AuthBlocEvent, AuthBlocState> {
  UserModel? _currentUser;
  AuthBlocFunc(AuthRepository repo, MemberService memberService)
    : super(const AuthBlocStateUninitialized(isLoading: true)) {
    on<AuthBlocEventInitialize>((event, emit) async {
      _currentUser = await repo.getCurrentUser(null);
      if (_currentUser == null) {
        emit(const AuthBlocStateLoggedOut(isLoading: false, exception: null));
      } else {
        emit(
          AuthBlocStateLoggedIn(
            isLoading: false,
            itsNumber: _currentUser!.itsNumber,
            user: _currentUser!,
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
      emit(
        AuthBlocStateError(
          isLoading: true,
          exception: "",
          currentUser: _currentUser,
        ),
      );
      try {
        bool isMember = await memberService.isMember(itsNo: event.itsNumber);
        devtools.log("is Member Present: $isMember");
        if (isMember) {
          await repo.register(
            UserModel(
              itsNumber: event.itsNumber,
              passwordHash: hashPassword(event.password),
              role: event.role,
              markaz: event.markaz,
            ),
          );
          emit(AuthBlocRegistered(isLoading: false, user: _currentUser));
        } else {
          emit(
            AuthBlocStateError(
              exception: "Member Not Found",
              isLoading: false,
              currentUser: _currentUser,
            ),
          );
        }
      } catch (e) {
        emit(
          AuthBlocStateError(
            isLoading: false,
            exception: e.toString(),
            currentUser: _currentUser,
          ),
        );
      }
    });

    on<AuthBlocEventNavigateToLogin>((event, emit) {
      emit(AuthBlocStateNavigatingToLogin(isLoading: false));
    });

    on<AuthBlocEventNavigateToRegister>((event, emit) {
      _currentUser = event.user;
      emit(
        AuthBlocStateNavigatingToRegister(isLoading: false, user: event.user),
      );
    });

    on<AuthBlocEventNavigateToDash>((event, emit) {
      emit(AuthBlocStatesNavigatingToDash(isLoading: false, user: event.user));
    });
  }
}
