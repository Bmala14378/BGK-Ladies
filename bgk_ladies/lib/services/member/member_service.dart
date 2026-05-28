import 'dart:developer' as devtools;

import 'package:bgk_ladies/enums/user_role_enum.dart';
import 'package:bgk_ladies/models/member_model.dart';
import 'package:bgk_ladies/repo/member/member_repo.dart';

class MemberService {
  final repo = MemberRepository();

  // ── Auth helpers ─────────────────────────────────────────────────────────

  Future<bool> isMember({required int itsNo}) async {
    try {
      final data = await repo.getMemberByIts(itsNo: itsNo);
      if (data != null) {
        return true;
      } else {
        devtools.log("Memeber NOt Found");
        return false;
      }
    } on Exception catch (e) {
      if (e.toString() == "Member Not Found") {
        return false;
      }
      return false;
    }
  }

  Future<MemberModel> getCurrentMemberInfo({required int itsNo}) async {
    final data = await repo.getMemberByIts(itsNo: itsNo);
    if (data != null) {
      return MemberModel.fromMap(data);
    } else {
      throw Exception("Member not found");
    }
  }

  // ── Scoped streams ────────────────────────────────────────────────────────

  Stream<List<MemberModel>> getMembers({
    required UserRoleEnum role,
    required String fieldId,
  }) {
    Stream<List<Map<String, dynamic>>> membersStream;
    switch (role) {
      case UserRoleEnum.groupleader:
        membersStream = repo.getGroupMembers(groupId: fieldId);
        break;
      case UserRoleEnum.captain:
        membersStream = repo.getAreaMembers(mohallahId: fieldId);
        break;
      case UserRoleEnum.superUser ||
          UserRoleEnum.officer ||
          UserRoleEnum.headAdmin:
        membersStream = repo.getAllMembers();
        break;
      case UserRoleEnum.onGroundAdmin:
        // onGroundAdmin bypasses Dashboard entirely — never reaches here
        return Stream.empty();
    }
    return membersStream.map(
      (list) => list.map((map) => MemberModel.fromMap(map)).toList(),
    );
  }

  // ── Write operations ──────────────────────────────────────────────────────

  Future<bool> memberExists({required String itsNumber}) async {
    return await repo.memberExists(itsNumber: itsNumber);
  }

  Future<void> addMember(MemberModel member) async {
    await repo.addMember(member);
  }

  Future<void> updateMember(MemberModel member) async {
    await repo.updateMember(member);
  }

  Future<void> updateMemberRemarks({
    required String itsNumber,
    required String remarks,
  }) async {
    await repo.updateMemberRemarks(itsNumber: itsNumber, remarks: remarks);
  }
}
