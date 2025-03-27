import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:table_order/src/services/firebase_notification_services.dart';
import 'package:table_order/src/services/firebase_user_services.dart';
import '../model/notification_model.dart';
import '../utils/file_handler.dart';
import '../utils/file_name_handler.dart';
import '../model/review_model.dart';
import 'firebase_restaurants_services.dart';

class FirebaseReviewServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseUserService _userService = FirebaseUserService();
  final FirebaseRestaurantsServices _restaurantsServices = FirebaseRestaurantsServices();
  final FirebaseNotificationServices _notificationServices = FirebaseNotificationServices();

  Future<void> submitReview(String restaurantId, String comment, int rating, List<XFile> images) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Người dùng chưa đăng nhập");
    }

    List<String> photoUrls = [];
    final reviewRef = _firestore.collection('restaurants').doc(restaurantId).collection('reviews').doc();

    for (XFile image in images) {
      final reviewStoragePath = getReviewsStoragePath(restaurantId, reviewRef.id, image.name);
      final photoUrl = await uploadImageToStorage(reviewStoragePath, File(image.path));
      if (photoUrl != null) {
        photoUrls.add(photoUrl);
      }
    }

    final review = ReviewModel(
      reviewId: reviewRef.id,
      userID: user.uid,
      rating: rating,
      comment: comment,
      photos: photoUrls,
      createdAt: Timestamp.now(),
    );

    await reviewRef.set(review.toFirestore());

    getAverageRating(restaurantId).then((averageRating) {
      _firestore.collection('restaurants').doc(restaurantId).update({
        'rating': averageRating,
      });
    });

    // Get the restaurant owner's ID and save the notification
    final ownerId = await _restaurantsServices.getOwnerId(restaurantId);
    if (ownerId != null) {
      final userName = await _userService.getUserName(user.uid);
      final notification = NotificationModel(
        notificationId: '${reviewRef.id}_$ownerId',
        recipientId: ownerId,
        relatedId: reviewRef.id,
        type: 'review',
        message: 'Đánh giá từ người dùng: $userName',
        restaurantId: restaurantId,
        isRead: false,
        isNotified: false,
        createdAt: Timestamp.now(),
      );
      await _notificationServices.saveNotification(notification);
    }
  }

  Future<void> updateReview(String restaurantId, String reviewId, String newComment, int newRating, List<XFile> newImages, List<String> existingImages) async {
    List<String> newImageUrls = [];
    for (XFile newImage in newImages) {
      final reviewStoragePath = getReviewsStoragePath(restaurantId, reviewId, newImage.name);
      final newImageUrl = await uploadImageToStorage(reviewStoragePath, File(newImage.path));
      if (newImageUrl != null) {
        newImageUrls.add(newImageUrl);
      }
    }

    final updatedReview = ReviewModel(
      reviewId: reviewId,
      userID: FirebaseAuth.instance.currentUser!.uid,
      rating: newRating,
      comment: newComment,
      photos: [...existingImages, ...newImageUrls],
      createdAt: Timestamp.now(),
    );

    await _firestore.collection('restaurants').doc(restaurantId).collection('reviews').doc(reviewId).update(updatedReview.toFirestore());

    getAverageRating(restaurantId).then((averageRating) {
      _firestore.collection('restaurants').doc(restaurantId).update({
        'rating': averageRating,
      });
    });
  }

  Future<void> deleteReview(String restaurantId, String reviewId, List<String> imageUrls) async {
    try {
      // Delete images from Firebase Storage
      for (String imageUrl in imageUrls) {
        final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await storageRef.delete();
      }

      // Delete the review document from Firestore
      await _firestore.collection('restaurants').doc(restaurantId).collection('reviews').doc(reviewId).delete();

      // Update the restaurant's average rating
      getAverageRating(restaurantId).then((averageRating) {
        _firestore.collection('restaurants').doc(restaurantId).update({
          'rating': averageRating,
        });
      });
    } catch (e) {
      throw Exception("Error deleting review: $e");
    }
  }

  Future<double> getAverageRating(String restaurantId) async {
    final snapshot = await _firestore.collection('restaurants').doc(restaurantId).collection('reviews').get();
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
    return _firestore.collection('restaurants').doc(restaurantId).collection('reviews').snapshots().map((snapshot) {
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