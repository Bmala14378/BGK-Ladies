import 'dart:developer' as devtools;

import 'package:bgk_ladies/constants/vars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemberRepository {
  final _memberCollection = FirebaseFirestore.instance.collection(
    Vars.memberCollection_Var,
  );

  Future<Map<String, dynamic>?> getMemberByIts({required int itsNo}) async {
    try {
      final doc = await _memberCollection.doc(itsNo.toString()).get();
      if (doc.exists) {
        return doc.data();
      } else {
        devtools.log("Member with ITS number $itsNo not found in database");
        throw Exception("Member not found");
      }
    } catch (e) {
      devtools.log("Error fetching personal info: $e");
      throw Exception("Could not find member profile");
    }
  }

  Stream<List<Map<String, dynamic>>> getGroupMembers({
    required String groupId,
  }) {
    try {
      return _memberCollection
          .where(Vars.glName_Var, isEqualTo: groupId)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      devtools.log("Error fetching group members: $e");
      throw Exception("Failed to fetch group members");
    }
  }

  Stream<List<Map<String, dynamic>>> getAreaMembers({
    required String mohallahId,
  }) {
    try {
      final members = _memberCollection
          .where(Vars.mohalla_Var, isEqualTo: mohallahId)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
      devtools.log(members.length.toString());
      return members;
    } catch (e) {
      devtools.log("Error fetching event members: $e");
      throw Exception("Failed to fetch event members");
    }
  }

  Stream<List<Map<String, dynamic>>> getAllMembers() {
    try {
      return _memberCollection.snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
      );
    } catch (e) {
      devtools.log("Error fetching all members: $e");
      throw Exception("Failed to fetch all members");
    }
  }
}
