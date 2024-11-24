import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:table_order/src/model/user_model.dart';
import 'package:table_order/src/utils/toast_utils.dart';

class FirebaseAuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      showToast('Email and password cannot be empty.');
      return null;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToast('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showToast('Wrong password provided for that user.');
      } else {
        showToast('An error occurred: ${e.message}');
      }
    }
    return null;
  }

  Future<User?> signUpWithEmailAndPassword(String email, String password,
      {String? username}) async {
    if (email.isEmpty || password.isEmpty) {
      showToast('Email and password cannot be empty.');
      return null;
    }

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null && username != null) {
        await user.updateProfile(displayName: username);

        // Lưu thông tin người dùng vào Firestore
        final String uid = user.uid;
        final UserModel userModel = UserModel(
          userId: uid,
          name: username,
          email: email,
          phone: "",
          profilePicture: "",
          role: "user",
          createdAt: Timestamp.now(),
        );

        if (kDebugMode) {
          print("Attempting to save user data: ${userModel.toFirestore()}");
        }

        // Store user data in Firestore
        await _firestore
            .collection("users")
            .doc(uid)
            .set(userModel.toFirestore());
        showToast("User data saved successfully.");
      }
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast('The account already exists for that email.');
      } else {
        showToast('An error occurred: ${e.message}');
      }
    }
    return null;
  }

  Future<String?> checkRole(User user) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('users').doc(user.uid).get();

    if (snapshot.exists) {
      // Retrieve user data as a UserModel
      final userModel = UserModel.fromFirebase(snapshot);
      return userModel.role;
    } else {
      showToast("User data not found");
      return null;
    }
  }
}
