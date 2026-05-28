import 'dart:developer' as devtools;

import 'package:bgk_ladies/bloc/user_mgmt/user_mgmt_bloc_events.dart';
import 'package:bgk_ladies/bloc/user_mgmt/user_mgmt_bloc_states.dart';
import 'package:bgk_ladies/models/user_model.dart';
import 'package:bgk_ladies/repo/auth/auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserMgmtBloc extends Bloc<UserMgmtBlocEvent, UserMgmtBlocState> {
  final AuthRepository _repo;

  UserMgmtBloc(AuthRepository repo)
    : _repo = repo,
      super(const UserMgmtBlocStateInitial()) {
    // ── Fetch all users (live stream) ───────────────────────────────────────
    on<UserMgmtBlocEventFetch>((event, emit) async {
      emit(const UserMgmtBlocStateLoading());
      await emit.forEach<List<UserModel>>(
        _repo.getAllUsers(),
        onData: (users) => UserMgmtBlocStateLoaded(
          allUsers: users,
          filteredUsers: users,
        ),
        onError: (error, stack) {
          devtools.log("UserMgmtBloc fetch error: $error");
          return UserMgmtBlocStateError(errorMessage: error.toString());
        },
      );
    });

    // ── Search (pure state transform — no Firestore call) ───────────────────
    on<UserMgmtBlocEventSearch>((event, emit) {
      final current = state;
      if (current is! UserMgmtBlocStateLoaded) return;

      final query = event.query.toLowerCase().trim();
      final filtered = query.isEmpty
          ? current.allUsers
          : current.allUsers.where((u) {
              return u.itsNumber.toString().contains(query) ||
                  u.role.name.toLowerCase().contains(query) ||
                  (u.markaz?.name.toLowerCase().contains(query) ?? false);
            }).toList();

      emit(
        UserMgmtBlocStateLoaded(
          allUsers: current.allUsers,
          filteredUsers: filtered,
        ),
      );
    });

    // ── Reset password ──────────────────────────────────────────────────────
    on<UserMgmtBlocEventResetPassword>((event, emit) async {
      try {
        await _repo.resetUserPassword(event.itsNumber);
        emit(
          UserMgmtBlocStateSuccess(
            message: "Password reset to ITS number for ${event.itsNumber}",
          ),
        );
      } catch (e) {
        devtools.log("UserMgmtBloc reset error: $e");
        emit(UserMgmtBlocStateError(errorMessage: e.toString()));
      }
    });

    // ── Delete user ─────────────────────────────────────────────────────────
    on<UserMgmtBlocEventDeleteUser>((event, emit) async {
      try {
        await _repo.deleteUser(event.itsNumber);
        emit(
          UserMgmtBlocStateSuccess(
            message: "User ${event.itsNumber} deleted successfully",
          ),
        );
      } catch (e) {
        devtools.log("UserMgmtBloc delete error: $e");
        emit(UserMgmtBlocStateError(errorMessage: e.toString()));
      }
    });
  }
}
