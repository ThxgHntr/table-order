import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_order/src/utils/toast_utils.dart';

class FirebaseAuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

}
