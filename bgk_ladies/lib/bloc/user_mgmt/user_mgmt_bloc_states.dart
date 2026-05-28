import 'package:bgk_ladies/models/user_model.dart';
import 'package:flutter/material.dart';

@immutable
abstract class UserMgmtBlocState {
  const UserMgmtBlocState();
}

class UserMgmtBlocStateInitial extends UserMgmtBlocState {
  const UserMgmtBlocStateInitial();
}

class UserMgmtBlocStateLoading extends UserMgmtBlocState {
  const UserMgmtBlocStateLoading();
}

class UserMgmtBlocStateLoaded extends UserMgmtBlocState {
  final List<UserModel> allUsers;
  final List<UserModel> filteredUsers;
  const UserMgmtBlocStateLoaded({
    required this.allUsers,
    required this.filteredUsers,
  });
}

class UserMgmtBlocStateSuccess extends UserMgmtBlocState {
  final String message;
  const UserMgmtBlocStateSuccess({required this.message});
}

class UserMgmtBlocStateError extends UserMgmtBlocState {
  final String errorMessage;
  const UserMgmtBlocStateError({required this.errorMessage});
}
