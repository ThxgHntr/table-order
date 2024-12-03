import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_model.dart';
import '../utils/file_name_handler.dart';
import '../utils/file_handler.dart';

class FirebaseUserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserProfile({
    required String name,
    required String phone,
    File? profileImage,
  }) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      // Update Firebase Auth user
      await user.updateDisplayName(name);
      // Note: Updating phone number requires re-authentication with a PhoneAuthCredential

      // Upload profile image if provided
      String? profileImageUrl;
      if (profileImage != null) {
        profileImageUrl = await _uploadProfileImage(user.uid, profileImage);
      }

      // Update Firestore user document
      final userModel = UserModel(
        userId: user.uid,
        name: name,
        email: user.email ?? '',
        phone: phone,
        profilePicture: profileImageUrl ?? user.photoURL ?? '',
        role: 'user', // Assuming role is 'user', adjust as needed
        createdAt: Timestamp.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toFirestore(), SetOptions(merge: true));
    }
  }

  Future<String?> _uploadProfileImage(String userId, File image) async {
    final path = getUserProfilePictureStoragePath(userId);
    return await uploadImageToStorage(path, image);
  }
}