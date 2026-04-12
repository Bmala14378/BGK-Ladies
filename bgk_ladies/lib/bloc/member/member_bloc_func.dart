// ignore: unused_import
import 'dart:developer' as devtools;

import 'package:bgk_ladies/bloc/member/member_bloc_events.dart';
import 'package:bgk_ladies/bloc/member/member_bloc_states.dart';
import 'package:bgk_ladies/enums/user_role_enum.dart';
import 'package:bgk_ladies/models/member_model.dart';
import 'package:bgk_ladies/services/member/member_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MemberBloc extends Bloc<MemberBlocEvent, MemberBlocState> {
  MemberBloc(MemberService memberService)
    : super(const InitialMemberBlocState(isLoading: true)) {
    on<MemberBlocEventInitialize>((event, emit) async {
      final user = event.user;

      try {
        final personalInfo = await memberService.getCurrentMemberInfo(
          itsNo: user.itsNumber,
        );

        String searchVal = "";
        if (user.role == UserRoleEnum.groupleader) {
          searchVal = personalInfo.glName;
        } else if (user.role == UserRoleEnum.captain) {
          searchVal = personalInfo.mohalla;
        }

        devtools.log(
          "Fetching members for role: ${user.role}, searchVal: $searchVal",
        );

        await emit.forEach<List<MemberModel>>(
          memberService.getMembers(role: user.role, fieldId: searchVal),
          onData: (members) => LoadedMemberBlocState(
            members: members,
            isLoading: false,
            userProfile: personalInfo,
          ),
          onError: (error, stack) => MemberStateError(error.toString()),
        );
      } catch (e) {
        emit(MemberStateError(e.toString()));
      }
    });
  }
}
