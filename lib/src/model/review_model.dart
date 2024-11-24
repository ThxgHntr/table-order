import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String userID;
  final String restaurantID;
  final int rating;
  final String comment;
  final List<String> photos;
  final Timestamp createdAt;

  ReviewModel({
    required this.userID,
    required this.restaurantID,
    required this.rating,
    required this.comment,
    required this.photos,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot data) {
    return ReviewModel(
      userID: data['userID'] ?? '',
      restaurantID: data['restaurantID'] ?? '',
      rating: data['rating'] ?? 0,
      comment: data['comment'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      createdAt: data['created_at'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userID': userID,
      'restaurantID': restaurantID,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'created_at': createdAt,
    };
  }
}