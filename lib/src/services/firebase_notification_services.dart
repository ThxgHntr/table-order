import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:table_order/src/model/notification_model.dart';

class FirebaseNotificationServices {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //ham xin quyen thong bao
  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> initNotification() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {

      },
    );
  }

  notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        channelDescription: 'No sound notification channel',
        importance: Importance.max,
        priority: Priority.high,
        playSound: false,
        sound: null,
        icon: '@mipmap/ic_launcher',
      ),
    );
  }

  Future showNotification({int id=0, String? title, String? body, String? payload}) async {
    return flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      await notificationDetails(),
    );
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markNotificationAsNotified(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'isNotified': true});
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

  Future<void> saveNotification(NotificationModel notification) async {
    final notificationsRef =
        FirebaseFirestore.instance.collection('notifications');
    try {
      await notificationsRef.add(notification.toFirestore());
      print("Thông báo đã được lưu thành công.");
    } catch (e) {
      print("Lỗi khi lưu thông báo: $e");
    }
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
      'isNotified': false,
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
