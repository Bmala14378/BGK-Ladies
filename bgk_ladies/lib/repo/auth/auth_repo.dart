import 'dart:developer' as devtools;

import 'package:bgk_ladies/constants/vars.dart';
import 'package:bgk_ladies/models/user_model.dart';
import 'package:bgk_ladies/repo/auth/auth_exception.dart';
import 'package:bgk_ladies/utilites/hash_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _cachedUser;
  UserModel? get cachedUser => _cachedUser;

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<UserModel?> login({
    required int itsNumber,
    required String password,
  }) async {
    try {
      String passwordHash = hashPassword(password);
      DocumentSnapshot doc = await _db
          .collection(Vars.userCollection_Var)
          .doc(itsNumber.toString())
          .get();
      if (doc.exists) {
        UserModel user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        if (user.passwordHash == passwordHash) {
          _cachedUser = user;
          return user;
        } else {
          devtools.log(
            "Password hash mismatch: expected ${user.passwordHash}, got $passwordHash",
          );
          throw Exception(InvalidPasswordException);
        }
      } else {
        devtools.log("User with ITS number $itsNumber not found in database");
        throw Exception(UserNotFoundException);
      }
    } on Exception catch (e) {
      if (e.toString().contains("UserNotFoundException") ||
          e.toString().contains("InvalidPasswordException")) {
        throw InvalidCredentialException();
      }
    }
    return null;
  }

  Future<void> register(UserModel user) async {
    try {
      DocumentReference docRef = _db
          .collection(Vars.userCollection_Var)
          .doc(user.itsNumber.toString());
      DocumentSnapshot doc = await docRef.get();
      if (doc.exists) {
        devtools.log("User with ITS number ${user.itsNumber} already exists");
        throw UserAlreadyInUseException;
      } else {
        await docRef.set(user.toMap());
      }
    } on Exception catch (e) {
      devtools.log("Error during registration: $e");
      if (e is UserAlreadyInUseException) {
        devtools.log("Error during registration: $e 3");
        rethrow;
      } else {
        devtools.log("Error during registration: $e 2");
        throw UnknownAuthException;
      }
    }
  }

  Future<void> logOut() async {
    return;
  }

  Future<UserModel?> getCurrentUser(String? itsNumber) async {
    if (itsNumber == null || itsNumber == "0") {
      return _cachedUser;
    }
    DocumentSnapshot doc = await _db
        .collection(Vars.userCollection_Var)
        .doc(itsNumber.toString())
        .get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_cachedUser == null) throw Exception("No user currently logged in.");

    String oldHash = hashPassword(oldPassword);
    if (_cachedUser!.passwordHash != oldHash) {
      throw Exception("Incorrect current password.");
    }

    String newHash = hashPassword(newPassword);
    await _db
        .collection(Vars.userCollection_Var)
        .doc(_cachedUser!.itsNumber.toString())
        .update({Vars.passwordHash_Var: newHash});

    _cachedUser = UserModel(
      itsNumber: _cachedUser!.itsNumber,
      passwordHash: newHash,
      role: _cachedUser!.role,
      markaz: _cachedUser!.markaz,
    );
  }

  // ── Admin: User Management ────────────────────────────────────────────────

  /// Streams the entire Users collection. Used by User Management screen.
  Stream<List<UserModel>> getAllUsers() {
    return _db.collection(Vars.userCollection_Var).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList(),
    );
  }

  /// Resets the password for any user to their ITS number (as a string).
  /// Only callable by admins — does NOT require knowing the current password.
  Future<void> resetUserPassword(int itsNumber) async {
    final newHash = hashPassword(itsNumber.toString());
    await _db
        .collection(Vars.userCollection_Var)
        .doc(itsNumber.toString())
        .update({Vars.passwordHash_Var: newHash});
    devtools.log("Password reset for ITS $itsNumber");
  }

  /// Deletes a user account from the Users collection.
  Future<void> deleteUser(int itsNumber) async {
    await _db
        .collection(Vars.userCollection_Var)
        .doc(itsNumber.toString())
        .delete();
    devtools.log("User deleted: ITS $itsNumber");
  }
}
