import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../model/review_model.dart';
import 'package:intl/intl.dart';

class ReviewManagementView extends StatefulWidget {
  final String restaurantId;
  const ReviewManagementView({super.key, required this.restaurantId});

  @override
  State<StatefulWidget> createState() => _ReviewManagementViewState();
}

class _ReviewManagementViewState extends State<ReviewManagementView> {
  final TextEditingController _replyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đánh giá'),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .collection('reviews')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading reviews'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reviews yet'));
          }
          final reviews = snapshot.data!.docs.map((doc) {
            return ReviewModel.fromFirestore(
                doc as DocumentSnapshot<Map<String, dynamic>>);
          }).toList();
          return ListView.separated(
            itemCount: reviews.length,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
            itemBuilder: (BuildContext context, int index) {
              final review = reviews[index];
              return ListTile(
                title: Text(review.comment),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < review.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text('Reviewed on: ${DateFormat.yMMMd().format(review.createdAt.toDate())}'),
                    if (review.reply.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Reply: ${review.reply}'),
                    ],
                  ],
                ),
                trailing: review.reply.isEmpty
                    ? IconButton(
                  icon: const Icon(Icons.reply, color: Colors.blue),
                  onPressed: () {
                    _showReplyDialog(review);
                  },
                )
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  void _showReplyDialog(ReviewModel review) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reply to Review'),
          content: TextField(
            controller: _replyController,
            decoration: const InputDecoration(
              labelText: 'Reply',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _replyToReview(review);
                Navigator.pop(context);
              },
              child: const Text('Reply'),
            ),
          ],
        );
      },
    );
  }

  void _replyToReview(ReviewModel review) {
    final reply = _replyController.text.trim();
    if (reply.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('reviews')
          .doc(review.reviewId)
          .update({'reply': reply});
      _replyController.clear();
    }
  }
}