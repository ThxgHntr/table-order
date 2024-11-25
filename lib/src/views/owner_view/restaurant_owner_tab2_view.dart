import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_order/src/utils/location_helper.dart';
import '../../model/restaurant_model.dart';
import '../../utils/file_handler.dart';

class RestaurantOwnerTab2View extends StatefulWidget {
  const RestaurantOwnerTab2View({super.key});

  @override
  State<StatefulWidget> createState() => _RestaurantOwnerTab2ViewState();
}

class _RestaurantOwnerTab2ViewState extends State<RestaurantOwnerTab2View> {
  late final Query ref;

  @override
  void initState() {
    super.initState();
    // Get the current user's userId
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      // Fetch restaurants where the ownerId matches the current user's ID
      ref = FirebaseFirestore.instance
          .collection('restaurants')
          .where('ownerId', isEqualTo: userId);
    } else {
      // If there's no userId, show no data
      if (kDebugMode) {
        print("No user data available.");
      }
    }
  }

  void _confirmRemoveRestaurant(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận xoá"),
          content: const Text("Bạn có chắc chắn muốn xoá nhà hàng này?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without action
              },
              child: const Text("Huỷ"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _removeRestaurant(id); // Remove restaurant
              },
              child: const Text(
                "Xoá",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _removeRestaurant(String restaurantId) async {
    try {
      // Xoá tất cả tệp trong thư mục `restaurant_pictures/$restaurantId/`
      final folderPath = 'restaurant_pictures/$restaurantId/';
      await deleteAllFilesInFolder(folderPath);

      // Xoá tài liệu nhà hàng trong Firestore
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xoá nhà hàng và tất cả ảnh liên quan')),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting restaurant: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi xoá nhà hàng: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: ref.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
          }

          final restaurants = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (BuildContext context, int index) {
              final restaurantData = restaurants[index];

              final restaurant = RestaurantModel.fromFirestore(
                  restaurantData as DocumentSnapshot<Map<String, dynamic>>);

              final createdAt = DateFormat('dd/MM/yyyy').format(
                restaurant.createdAt.toDate(),
              );

              // Define the restaurant status based on the type
              String statusText;
              Color statusColor;

              switch (restaurant.state) {
                case 0:
                  statusText = 'Chờ duyệt';
                  statusColor = Colors.yellow;
                  break;
                case 1:
                  statusText = 'Đã duyệt';
                  statusColor = Colors.green;
                  break;
                case 2:
                  statusText = 'Từ chối';
                  statusColor = Colors.red;
                  break;
                default:
                  return const SizedBox.shrink();
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  title: Text(restaurant.name), // Restaurant name
                  subtitle: FutureBuilder<String>(
                    future: getAddressFromGeopoint(restaurant.location),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final address = snapshot.data ?? 'Unknown address';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(address), // Restaurant address
                            Text('Ngày tạo: $createdAt'), // Created date
                          ],
                        );
                      }
                    },
                  ),
                  trailing: restaurant.state == 0
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _confirmRemoveRestaurant(restaurant.restaurantId),
                        )
                      : null, // Show delete button only if state is '0'
                ),
              );
            },
          );
        },
      ),
    );
  }
}
