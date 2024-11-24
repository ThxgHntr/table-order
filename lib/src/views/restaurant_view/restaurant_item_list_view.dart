import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:table_order/src/views/restaurant_view/restaurant_item_details_view.dart';
import '../../model/restaurant_model.dart';
import 'dart:io';

import '../../utils/location_helper.dart';

class RestaurantItemListView extends StatefulWidget {
  const RestaurantItemListView({super.key});

  static const routeName = '/';

  @override
  State<StatefulWidget> createState() => _RestaurantItemListViewState();
}

class _RestaurantItemListViewState extends State<RestaurantItemListView> {
  Position? currentPosition;

  // Lấy vị trí hiện tại của người dùng
  Future<void> getUserLocation() async {
    currentPosition = await getCurrentLocation();
  }

  Future<String> getImageUrl(String imagePath) async {
    try {
      if (imagePath.startsWith('/data/user/0/')) {
        // Handle local file path (local image in cache or directory)
        return imagePath;
      } else {
        // If it's a Firebase Storage path, get the URL
        final ref = FirebaseStorage.instance.ref().child(imagePath);
        final url = await ref.getDownloadURL();
        return url;
      }
    } catch (e) {
      // Return a placeholder image if there's an error
      return 'https://via.placeholder.com/150';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Query restaurantRef = FirebaseFirestore.instance
        .collection('restaurants')
        .where('state', isEqualTo: 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nhà hàng gần bạn',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: restaurantRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Đã xảy ra lỗi!"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Không có nhà hàng nào."));
          }

          final restaurants = snapshot.data!.docs;

          return FutureBuilder(
            future: getUserLocation(), // Lấy vị trí người dùng trước khi tính khoảng cách
            builder: (context, userLocationSnapshot) {
              if (userLocationSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final restaurantData = restaurants[index];
                  final restaurant = RestaurantModel.fromFirestore(
                      restaurantData as DocumentSnapshot<Map<String, dynamic>>);
                  final restaurantId = restaurantData.id;
                  final restaurantName = restaurant.name.isNotEmpty
                      ? restaurant.name
                      : "Chưa có tên";
                  final restaurantLocation = restaurant.location;
                  double distance = 0.0;

                  if (currentPosition != null) {
                    distance = Geolocator.distanceBetween(
                      currentPosition!.latitude,
                      currentPosition!.longitude,
                      restaurantLocation.latitude,
                      restaurantLocation.longitude,
                    ) / 1000; // Convert to kilometers
                  }

                  final imageUrl = restaurant.photos.isNotEmpty
                      ? getImageUrl(restaurant.photos.first)
                      : Future.value('https://via.placeholder.com/150');

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 5,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantItemDetailsView(
                              restaurantId: restaurantId,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: FutureBuilder<String>(
                              future: imageUrl,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                if (snapshot.hasError || !snapshot.hasData) {
                                  return const Icon(Icons.broken_image);
                                }

                                final image = snapshot.data!;
                                return ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                                  child: image.startsWith('http')
                                      ? Image.network(
                                    image,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                                  )
                                      : Image.file(
                                    File(image),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              restaurantName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16),
                                    SizedBox(width: 4),
                                    Text('${distance.toStringAsFixed(1)} km'),
                                  ],
                                ),
                                Row(
                                  children: const [
                                    Icon(Icons.star, size: 16, color: Colors.yellow),
                                    Text('5.0'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

