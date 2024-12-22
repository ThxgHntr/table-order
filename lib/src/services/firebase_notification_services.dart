import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseNotificationServices {
  Future<void> markNotificationAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllNotificationsAsRead(String recipientId) async {
    final notificationsRef =
        FirebaseFirestore.instance.collection('notifications');

    final notifications = await notificationsRef
        .where('recipientId', isEqualTo: recipientId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = FirebaseFirestore.instance.batch();

    for (final notification in notifications.docs) {
      batch.update(notification.reference, {'isRead': true});
    }

    await batch.commit();
  }

  static Future<void> addSampleNotification(String recipientId) async {
    final notificationsRef =
        FirebaseFirestore.instance.collection('notifications');

    final sampleData = {
      'recipientId': 'LKBA7wXOmSSipI3gJpGzfNJbb4v2',
      'relatedId': 'gQT5dhNtAnZE6d7VLPBu',
      'type': 'review',
      'message': 'Bạn nhận được một đánh giá mới!',
      'restaurantId': 'LKBA7wXOmSSipI3gJpGzfNJbb4v21732452458221',
      'isRead': false,
      'created_at': Timestamp.now(),
    };

    try {
      await notificationsRef.add(sampleData);
      print("Dữ liệu mẫu đã được thêm thành công.");
    } catch (e) {
      print("Lỗi khi thêm dữ liệu mẫu: $e");
    }
  }
}
