import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:table_order/src/utils/toast_utils.dart';

class FirebaseAuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _dbRef = FirebaseDatabase.instance.ref();

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      showToast('Email and password cannot be empty.');
      return null;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
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


  Future<User?> signUpWithEmailAndPassword(String email, String password, {String? username}) async {
    if (email.isEmpty || password.isEmpty) {
      showToast('Email and password cannot be empty.');
      return null;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null && username != null) {
        await user.updateProfile(displayName: username);

        // Lưu thông tin người dùng vào Firebase Realtime Database
        final String uid = user.uid;
        final Map<String, dynamic> userMap = {
          "uid": uid,
          "name": username,
          "email": email,
          "phone": "",
          "created_at": DateTime.now().millisecondsSinceEpoch,
          "role": "user",
          "profilePhoto": ""
        };

        if (kDebugMode) {
          print("Attempting to save user data: $userMap");
        }
        await _dbRef.child("users").child(uid).set(userMap);
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
      final DatabaseEvent event = await _dbRef.child("users").child(user.uid).once();
      final snapshot = event.snapshot;

      if (snapshot.value != null) {
        final Map<String, dynamic> values = Map<String, dynamic>.from(snapshot.value as Map);
        return values["role"] as String?;
      } else {
        showToast("User data not found");
        return null;
      }
  }
}
