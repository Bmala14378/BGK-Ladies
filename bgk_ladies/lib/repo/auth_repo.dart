import 'dart:developer' as devtools;

import 'package:bgk_ladies/constants/vars.dart';
import 'package:bgk_ladies/models/user_model.dart';
import 'package:bgk_ladies/repo/auth_exception.dart';
import 'package:bgk_ladies/utilites/hash_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel?> login(int itsNumber, String password) async {
    try {
      String passwordHash = hashPassword(password);
      DocumentSnapshot doc = await _db
          .collection(Vars.userCollection_Var)
          .doc(itsNumber.toString())
          .get();
      if (doc.exists) {
        UserModel user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        if (user.passwordHash == passwordHash) {
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
    } catch (e) {
      devtools.log("Error during login: $e");
      throw Exception(UnknownAuthException);
    }
  }

  Future<void> register(UserModel user) async {
    try {
      DocumentReference docRef = _db
          .collection(Vars.userCollection_Var)
          .doc(user.itsNumber.toString());
      DocumentSnapshot doc = await docRef.get();
      if (doc.exists) {
        devtools.log("User with ITS number ${user.itsNumber} already exists");
        throw Exception(UserAlreadyInUseException);
      } else {
        await docRef.set(user.toMap());
      }
    } catch (e) {
      devtools.log("Error during registration: $e");
      throw Exception(UnknownAuthException);
    }
  }
}
