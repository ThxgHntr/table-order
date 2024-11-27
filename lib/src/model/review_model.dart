// lib/src/model/review_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String userID;
  final int rating;
  final String comment;
  final List<String> photos; // Ensure this is a list
  final Timestamp createdAt;
  final String reply;

  ReviewModel({
    this.reviewId = '',
    required this.userID,
    required this.rating,
    required this.comment,
    required this.photos,
    required this.createdAt,
    this.reply = '',
  });

  factory ReviewModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return ReviewModel(
      reviewId: snapshot.id,
      userID: data['userID'] ?? '',
      rating: data['rating'] ?? 0,
      comment: data['comment'] ?? '',
      photos: data['photos'] is Iterable ? List<String>.from(data['photos']) : [], // Convert to list
      createdAt: data['created_at'] ?? Timestamp.now(),
      reply: data['reply'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userID': userID,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'created_at': createdAt,
      'reply': reply,
    };
  }
}