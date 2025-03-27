import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_order/src/views/restaurant_view/restaurant_review_view.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../services/firebase_notification_services.dart';
import '../../utils/custom_colors.dart';

class NotifyPageView extends StatefulWidget {
  const NotifyPageView({super.key});

  static const routeName = '/notify_page';

  @override
  State<NotifyPageView> createState() => _NotifyPageViewState();
}

class _NotifyPageViewState extends State<NotifyPageView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseNotificationServices _notificationServices =
      FirebaseNotificationServices();

  Future<void> _markAllAsRead() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      await _notificationServices.markAllNotificationsAsRead(currentUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Thông báo'),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Text('Không có thông báo nào.'),
        ),
      );
    }

    final currentUserId = currentUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_chat_read),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('recipientId', isEqualTo: currentUserId)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có thông báo nào.'));
          }

          final notifications = snapshot.data!.docs;

          // Check for new notifications only once when data is fetched
          for (var notification in notifications) {
            final notificationId = notification.id;
            final isNotified = notification['isNotified'];

            // If notification hasn't been shown before, show it
            if (!isNotified) {
              _notificationServices.showNotification(
                title: 'Thông báo mới',
                body: notification['message'],
              );

              // Update notification status to 'isNotified: true'
              FirebaseFirestore.instance
                  .collection('notifications')
                  .doc(notificationId)
                  .update({'isNotified': true});
            }
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final String message = notification['message'];
              final String type = notification['type'];
              final bool isRead = notification['isRead'];
              final Timestamp createdAt = notification['created_at'];
              final String relatedId = notification['relatedId'];
              final String restaurantId = notification['restaurantId'];
              final String notificationId = notification.id;

              final now = DateTime.now();
              final notificationTime = createdAt.toDate();
              final formattedTime = now.difference(notificationTime).inDays > 1
                  ? DateFormat('dd/MM/yyyy HH:mm').format(notificationTime)
                  : timeago.format(notificationTime, locale: 'vi');

              return InkWell(
                onTap: () async {
                  // Mark the notification as read when clicked
                  await _notificationServices
                      .markNotificationAsRead(notificationId);

                  // Navigate to the corresponding screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantReviewView(
                        restaurantId: restaurantId,
                        relatedId: relatedId,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [customRed, primaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          type == 'review' ? Icons.comment : Icons.event_note,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isRead ? Colors.grey : Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formattedTime,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      isRead
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.mark_chat_read,
                              color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
