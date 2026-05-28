import 'package:bgk_ladies/models/member_model.dart';
import 'package:bgk_ladies/models/user_model.dart';
import 'package:flutter/material.dart';

@immutable
abstract class MemberBlocEvent {
  const MemberBlocEvent();
}

class MemberBlocEventInitialize extends MemberBlocEvent {
  final UserModel user;
  const MemberBlocEventInitialize({required this.user});
}

class MemberBlocEventReset extends MemberBlocEvent {
  const MemberBlocEventReset();
}

class MemberBlocEventAddMember extends MemberBlocEvent {
  final MemberModel member;
  const MemberBlocEventAddMember({required this.member});
}

class MemberBlocEventUpdateMember extends MemberBlocEvent {
  final MemberModel member;
  const MemberBlocEventUpdateMember({required this.member});
}

class MemberBlocEventUpdateRemarks extends MemberBlocEvent {
  final String itsNumber;
  final String remarks;
  const MemberBlocEventUpdateRemarks({
    required this.itsNumber,
    required this.remarks,
  });
}
