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

class MemberBlocEventReset  extends MemberBlocEvent {
  const MemberBlocEventReset();
}
