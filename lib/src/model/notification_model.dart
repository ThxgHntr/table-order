import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notificationId;
  final String recipientId;
  final String relatedId;
  final String type;
  final String message;
  final String restaurantId;
  final bool isRead;
  final Timestamp createdAt;

  NotificationModel({
    required this.notificationId,
    required this.recipientId,
    required this.relatedId,
    required this.type,
    required this.message,
    required this.restaurantId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return NotificationModel(
      notificationId: snapshot.id,
      recipientId: data['recipientId'] ?? '',
      relatedId: data['relatedId'] ?? '',
      type: data['type'] ?? '',
      message: data['message'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: data['created_at'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'relatedId': relatedId,
      'type': type,
      'message': message,
      'restaurantId': restaurantId,
      'isRead': isRead,
      'created_at': createdAt,
    };
  }
}
