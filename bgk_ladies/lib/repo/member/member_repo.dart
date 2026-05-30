import 'dart:developer' as devtools;

import 'package:bgk_ladies/constants/vars.dart';
import 'package:bgk_ladies/models/member_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemberRepository {
  final _memberCollection = FirebaseFirestore.instance.collection(
    Vars.memberCollection_Var,
  );

  // ── Read ────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getMemberByIts({required int itsNo}) async {
    try {
      final doc = await _memberCollection.doc(itsNo.toString()).get();
      if (doc.exists) {
        return doc.data();
      } else {
        devtools.log("Member with ITS number $itsNo not found in database");
        return null;
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
      return _memberCollection
          .where(Vars.mohalla_Var, isEqualTo: mohallahId)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
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

  // ── Write ───────────────────────────────────────────────────────────────────

  /// Returns true if a member document already exists for [itsNumber].
  Future<bool> memberExists({required String itsNumber}) async {
    try {
      final doc = await _memberCollection.doc(itsNumber).get();
      return doc.exists;
    } catch (e) {
      devtools.log("Error checking member existence: $e");
      throw Exception("Failed to check if member exists");
    }
  }

  /// Creates a new member document. Caller must ensure the ITS does not exist.
  Future<void> addMember(MemberModel member) async {
    try {
      await _memberCollection.doc(member.itsNumber).set(member.toMap());
    } catch (e) {
      devtools.log("Error adding member: $e");
      throw Exception("Failed to add member");
    }
  }

  /// Overwrites all editable fields of an existing member document.
  Future<void> updateMember(MemberModel member) async {
    try {
      await _memberCollection.doc(member.itsNumber).update(member.toMap());
    } catch (e) {
      devtools.log("Error updating member: $e");
      throw Exception("Failed to update member");
    }
  }

  /// Permanently removes a member document. Attendance records under
  /// Events/{eventId}/Attendance/{itsNumber} are not touched.
  Future<void> deleteMember({required String itsNumber}) async {
    try {
      await _memberCollection.doc(itsNumber).delete();
    } catch (e) {
      devtools.log("Error deleting member: $e");
      throw Exception("Failed to delete member");
    }
  }

  /// Updates only the remarks field for a member.
  Future<void> updateMemberRemarks({
    required String itsNumber,
    required String remarks,
  }) async {
    try {
      await _memberCollection
          .doc(itsNumber)
          .update({Vars.remarks_Var: remarks});
    } catch (e) {
      devtools.log("Error updating remarks: $e");
      throw Exception("Failed to update remarks");
    }
  }
}
