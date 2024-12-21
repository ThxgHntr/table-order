import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
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
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('restaurants')
              .doc(restaurantId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                !snapshot.data!.exists) {
              return const Text('Restaurant');
            }
            final restaurant = snapshot.data!.data() as Map<String, dynamic>;
            //lay restaurant photo dau tien
            final avatarUrl = restaurant['photos'][0] ?? '';
            final restaurantName = restaurant['name'] ?? 'Restaurant';

            return Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(avatarUrl),
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  restaurantName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
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
      return userDoc.data()?['name'] ?? 'Ẩn danh';
    }
    return 'Ẩn danh';
  }

  @override
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<String>>(
      future: Future.wait([_getUserAvatar(userId), _getUserName(userId)]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Lỗi tải dữ liệu');
        }
        final userAvatar = snapshot.data![0];
        final userName = snapshot.data![1];
        final reviewTime = review.createdAt.toDate();
        final now = DateTime.now();

        // Set the locale to Vietnamese
        timeago.setLocaleMessages('vi', timeago.ViMessages());

        final formattedTime = now.difference(reviewTime).inDays > 1
            ? DateFormat('dd/MM/yyyy HH:mm').format(reviewTime)
            : timeago.format(reviewTime, locale: 'vi');

        return Card(
          elevation: 1,
          color: isDarkTheme ? Colors.grey[800] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.network(
                        userAvatar,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkTheme ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formattedTime,
                                style: TextStyle(
                                  color: isDarkTheme ? Colors.white70 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < review.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              );
                            }),
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
                                  title: const Text('Xoá đánh giá'),
                                  content: const Text('Bạn có chắc chắn muốn xoá đánh giá này không?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        onDelete();
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Xoá'),
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
                                      title: const Text('Cập nhật đánh giá'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            controller: commentController,
                                            decoration: const InputDecoration(labelText: 'Đánh giá của bạn'),
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
                                            label: const Text('Chọn ảnh mới'),
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
                                          child: const Text('Hủy'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            onUpdate(commentController.text, rating, newImages, existingImages);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Cập nhật'),
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
                                Text('Xoá'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 1,
                            child: Row(
                              children: const [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Chỉnh sửa'),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                if (review.comment.isNotEmpty)
                  Text(
                    review.comment,
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                const SizedBox(height: 5),
                if (review.photos.isNotEmpty)
                  Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: review.photos.map((photo) => GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                                        maxHeight: MediaQuery.of(context).size.height * 0.9,
                                      ),
                                      child: Image.network(photo),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              height: 100,
                              width: 100,
                              margin: const EdgeInsets.only(right: 8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(photo),
                                ),
                              ),
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                if (review.reply.isNotEmpty)
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Phản hồi của nhà hàng:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          review.reply,
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
