import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/file_handler.dart';
import '../utils/file_name_handler.dart';

class FirebaseReviewServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitReview(String restaurantId, String comment, int rating,
      List<XFile> images) async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Người dùng chưa đăng nhập");
    }

    List<String> photoUrls = [];
    final reviewRef = _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('reviews')
        .doc();

    for (XFile image in images) {
      final reviewStoragePath = getReviewsStoragePath(restaurantId, reviewRef.id, image.name);
      final photoUrl = await uploadImageToStorage(reviewStoragePath, File(image.path));
      if (photoUrl != null) {
        photoUrls.add(photoUrl);
      }
    }

    final review = {
      'userID': user.uid,
      'rating': rating,
      'comment': comment,
      'created_at': FieldValue.serverTimestamp(),
      'photos': photoUrls,
    };

    await reviewRef.set(review);

    getAverageRating(restaurantId).then((averageRating) {
      _firestore.collection('restaurants').doc(restaurantId).update({
        'rating': averageRating,
      });
    });
  }

  Future<void> updateReview(
      String restaurantId,
      String reviewId,
      String newComment,
      int newRating,
      List<XFile> newImages,
      List<String> existingImages) async {
    List<String> newImageUrls = [];
    for (XFile newImage in newImages) {
      final reviewStoragePath = getReviewsStoragePath(restaurantId, reviewId, newImage.name);
      final newImageUrl = await uploadImageToStorage(reviewStoragePath, File(newImage.path));
      if (newImageUrl != null) {
        newImageUrls.add(newImageUrl);
      }
    }

    final updatedReview = {
      'comment': newComment,
      'rating': newRating,
      'photos': [...existingImages, ...newImageUrls],
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('reviews')
        .doc(reviewId)
        .update(updatedReview);

    getAverageRating(restaurantId).then((averageRating) {
      _firestore.collection('restaurants').doc(restaurantId).update({
        'rating': averageRating,
      });
    });
  }

  Future<void> deleteReview(
      String restaurantId, String reviewId, List<String> imageUrls) async {
    for (String imageUrl in imageUrls) {
      final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
    }
    final folderRef = FirebaseStorage.instance
        .ref()
        .child('restaurant_pictures/$restaurantId/review_images/$reviewId');
    final ListResult result = await folderRef.listAll();
    for (Reference fileRef in result.items) {
      await fileRef.delete();
    }
    await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('reviews')
        .doc(reviewId)
        .delete();

    getAverageRating(restaurantId).then((averageRating) {
      _firestore.collection('restaurants').doc(restaurantId).update({
        'rating': averageRating,
      });
    });
  }

  //ham lay du lieu review rating cua restaurant sau do tinh trung binh roi tra ve gia tri
  Future<double> getAverageRating(String restaurantId) async {
    final snapshot = await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('reviews')
        .get();
    if (snapshot.docs.isEmpty) {
      return 0;
    }
    double totalRating = 0;
    for (DocumentSnapshot doc in snapshot.docs) {
      totalRating += doc['rating'];
    }
    return totalRating / snapshot.docs.length;
  }

  Stream<double> getAverageRatingStream(String restaurantId) {
    return _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('reviews')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return 0.0;
      }
      double totalRating = 0;
      for (var doc in snapshot.docs) {
        totalRating += doc['rating'];
      }
      return totalRating / snapshot.docs.length;
    });
  }
}