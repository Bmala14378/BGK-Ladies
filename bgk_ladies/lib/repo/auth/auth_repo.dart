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
}
