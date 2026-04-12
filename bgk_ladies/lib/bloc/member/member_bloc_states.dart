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
