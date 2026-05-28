// ignore: unused_import
import 'dart:developer' as devtools;

import 'package:bgk_ladies/bloc/member/member_bloc_events.dart';
import 'package:bgk_ladies/bloc/member/member_bloc_states.dart';
import 'package:bgk_ladies/enums/user_role_enum.dart';
import 'package:bgk_ladies/models/member_model.dart';
import 'package:bgk_ladies/services/member/member_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MemberBloc extends Bloc<MemberBlocEvent, MemberBlocState> {
  final MemberService _memberService;

  MemberBloc(MemberService memberService)
    : _memberService = memberService,
      super(const InitialMemberBlocState(isLoading: true)) {
    // ── Initialize (load scoped member list) ─────────────────────────────────
    on<MemberBlocEventInitialize>((event, emit) async {
      final user = event.user;

      try {
        final personalInfo = await _memberService.getCurrentMemberInfo(
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
          _memberService.getMembers(role: user.role, fieldId: searchVal),
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

    // ── Reset ─────────────────────────────────────────────────────────────────
    on<MemberBlocEventReset>((event, emit) {
      emit(const InitialMemberBlocState(isLoading: true));
    });

    // ── Add Member ────────────────────────────────────────────────────────────
    on<MemberBlocEventAddMember>((event, emit) async {
      try {
        final exists = await _memberService.memberExists(
          itsNumber: event.member.itsNumber,
        );
        if (exists) {
          emit(
            MemberStateError(
              "Member with ITS ${event.member.itsNumber} already exists",
            ),
          );
          return;
        }
        await _memberService.addMember(event.member);
        emit(
          const MemberStateOperationSuccess(message: "Member added successfully"),
        );
        // The existing stream (from Firestore) auto-refreshes the member list
      } catch (e) {
        emit(MemberStateError(e.toString()));
      }
    });

    // ── Update Member ─────────────────────────────────────────────────────────
    on<MemberBlocEventUpdateMember>((event, emit) async {
      try {
        await _memberService.updateMember(event.member);
        emit(
          const MemberStateOperationSuccess(
            message: "Member updated successfully",
          ),
        );
      } catch (e) {
        emit(MemberStateError(e.toString()));
      }
    });

    // ── Update Remarks ────────────────────────────────────────────────────────
    on<MemberBlocEventUpdateRemarks>((event, emit) async {
      try {
        await _memberService.updateMemberRemarks(
          itsNumber: event.itsNumber,
          remarks: event.remarks,
        );
        emit(const MemberStateRemarksUpdated());
      } catch (e) {
        emit(MemberStateError(e.toString()));
      }
    });
  }
}
