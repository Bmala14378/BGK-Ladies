import 'package:bgk_ladies/models/member_model.dart';
import 'package:flutter/material.dart';

@immutable
abstract class MemberBlocState {
  final bool isLoading;
  const MemberBlocState({required this.isLoading});
}

class InitialMemberBlocState extends MemberBlocState {
  const InitialMemberBlocState({required super.isLoading});
}

class LoadedMemberBlocState extends MemberBlocState {
  final List<MemberModel> members;
  final MemberModel? userProfile;
  const LoadedMemberBlocState({
    required super.isLoading,
    required this.members,
    required this.userProfile,
  });
}

class MemberStateError extends MemberBlocState {
  final String errorMessage;
  const MemberStateError(this.errorMessage) : super(isLoading: false);
}

/// Emitted after a successful remarks update so listeners can show a SnackBar.
class MemberStateRemarksUpdated extends MemberBlocState {
  const MemberStateRemarksUpdated() : super(isLoading: false);
}

/// Emitted after a successful add or update operation.
class MemberStateOperationSuccess extends MemberBlocState {
  final String message;
  const MemberStateOperationSuccess({required this.message})
    : super(isLoading: false);
}
