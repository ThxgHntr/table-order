import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:table_order/src/services/firebase_restaurants_services.dart';
import 'package:table_order/src/services/firebase_review_services.dart';
import '../widgets/add_review_form.dart';
import '../../model/review_model.dart';

class RestaurantReviewView extends StatelessWidget {
  final String restaurantId;

  const RestaurantReviewView({super.key, required this.restaurantId});

  static const routeName = '/restaurant_review';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final FirebaseReviewServices service = FirebaseReviewServices();
    final FirebaseRestaurantsServices restaurantService =
        FirebaseRestaurantsServices();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá & Bình luận'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('restaurants')
                      .doc(restaurantId)
                      .collection('reviews')
                      .orderBy('created_at', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      debugPrint("Error: ${snapshot.error}");
                      return const Text('Error loading reviews');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      debugPrint("No reviews found");
                      return const Text('No reviews yet');
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
                        return _ReviewCard(
                          review: review,
                          user: user,
                          userId: review.userID,
                          onDelete: () => service.deleteReview(
                              restaurantId, review.reviewId, review.photos),
                          onUpdate: (newComment, newRating, newImages,
                                  existingImages) =>
                              service.updateReview(
                                  restaurantId,
                                  review.reviewId,
                                  newComment,
                                  newRating,
                                  newImages,
                                  existingImages),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              //neu auth id cua user khong phai la owner thi hien thi form review
              FutureBuilder<String?>(
                future: restaurantService.getOwnerId(restaurantId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final ownerId = snapshot.data;
                  if (user != null && user.uid != ownerId) {
                    return AddReviewForm(restaurantId: restaurantId);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final User? user;
  final VoidCallback onDelete;
  final String userId;
  final Function(String, int, List<XFile>, List<String>) onUpdate;

  const _ReviewCard({
    required this.review,
    this.user,
    required this.userId,
    required this.onDelete,
    required this.onUpdate,
  });

  Future<String> _getUserAvatar(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data()?['profilePicture'] ?? '';
    }
    return '';
  }

  Future<String> _getUserName(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data()?['name'] ?? 'Anonymous';
    }
    return 'Anonymous';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: Future.wait([_getUserAvatar(userId), _getUserName(userId)]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Error loading user data');
        }
        final userAvatar = snapshot.data![0];
        final userName = snapshot.data![1];

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _AvatarImage(userAvatar),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${review.createdAt.toDate()}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (user?.uid == userId)
                      PopupMenuButton<int>(
                        icon: const Icon(Icons.more_horiz),
                        onSelected: (value) {
                          if (value == 0) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text('Are you sure you want to delete this review?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        onDelete();
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else if (value == 1) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                final TextEditingController commentController = TextEditingController(text: review.comment);
                                int rating = review.rating;
                                List<XFile> newImages = [];
                                List<String> existingImages = List.from(review.photos);

                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      title: const Text('Update Review'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            controller: commentController,
                                            decoration: const InputDecoration(labelText: 'Comment'),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: List.generate(5, (index) {
                                              return IconButton(
                                                icon: Icon(
                                                  index < rating ? Icons.star : Icons.star_border,
                                                  color: Colors.amber,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    rating = index + 1;
                                                  });
                                                },
                                              );
                                            }),
                                          ),
                                          const SizedBox(height: 8),
                                          if (existingImages.isNotEmpty)
                                            Wrap(
                                              spacing: 8.0,
                                              runSpacing: 8.0,
                                              children: existingImages.map((image) {
                                                return Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                      child: Image.network(
                                                        image,
                                                        height: 100,
                                                        width: 100,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Positioned(
                                                      right: 0,
                                                      child: IconButton(
                                                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                                                        onPressed: () {
                                                          setState(() {
                                                            existingImages.remove(image);
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          const SizedBox(height: 8),
                                          TextButton.icon(
                                            onPressed: () async {
                                              final ImagePicker picker = ImagePicker();
                                              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                              if (image != null) {
                                                setState(() {
                                                  newImages.add(image);
                                                });
                                              }
                                            },
                                            icon: const Icon(Icons.add_a_photo, color: Colors.deepOrange),
                                            label: const Text('Pick Images'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.deepOrange,
                                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          if (newImages.isNotEmpty)
                                            Wrap(
                                              spacing: 8.0,
                                              runSpacing: 8.0,
                                              children: newImages.map((image) {
                                                return ClipRRect(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  child: Image.file(
                                                    File(image.path),
                                                    height: 100,
                                                    width: 100,
                                                    fit: BoxFit.cover,
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                        ],
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
                                            onUpdate(commentController.text, rating, newImages, existingImages);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Update'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 0,
                            child: Row(
                              children: const [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 1,
                            child: Row(
                              children: const [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Update'),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                if (review.comment.isNotEmpty) Text(review.comment),
                if (review.photos.isNotEmpty)
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: Image.network(review.photos.first),
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 200,
                          margin: const EdgeInsets.only(top: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(review.photos.first),
                            ),
                          ),
                        ),
                      ),
                      if (review.photos.length > 1)
                        Row(
                          children: review.photos.skip(1).take(2).map((photo) => Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      child: Image.network(photo),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                height: 100,
                                margin: const EdgeInsets.only(top: 8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(photo),
                                  ),
                                ),
                              ),
                            ),
                          )).toList(),
                        ),
                    ],
                  ),
                const SizedBox(height: 8),
                if (review.reply.isNotEmpty)
                  Text(
                    'Reply from restaurant: ${review.reply}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AvatarImage extends StatelessWidget {
  final String url;

  const _AvatarImage(this.url);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/images/placeholder.png', fit: BoxFit.cover);
          },
        ),
      ),
    );
  }
}