import 'package:bgk_ladies/enums/user_role_enum.dart';
import 'package:bgk_ladies/models/member_model.dart';

import 'package:bgk_ladies/repo/member/member_repo.dart';

class MemberService {
  final repo = MemberRepository();
  Future<MemberModel> getCurrentMemberInfo({required int itsNo}) async {
    final data = await repo.getMemberByIts(itsNo: itsNo);

    if (data != null) {
      return MemberModel.fromMap(data);
    } else {
      throw Exception("Member not found");
    }
  }

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
      default:
        throw Exception("Invalid user role");
    }
    return membersStream.map(
      (list) => list.map((map) => MemberModel.fromMap(map)).toList(),
    );
  }
}
