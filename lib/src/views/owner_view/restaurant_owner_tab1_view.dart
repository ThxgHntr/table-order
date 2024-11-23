import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_order/src/utils/location_helper.dart';
import 'package:table_order/src/views/owner_view/restaurant_owner_management_view.dart';
import '../../model/restaurant_model.dart';

class RestaurantOwnerTab1View extends StatefulWidget {
  const RestaurantOwnerTab1View({super.key});

  @override
  State<StatefulWidget> createState() => _RestaurantOwnerTab1ViewState();
}

class _RestaurantOwnerTab1ViewState extends State<RestaurantOwnerTab1View> {
  late final Query ref;

  @override
  void initState() {
    super.initState();
    // Lấy userId của người dùng hiện tại
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      // Lọc danh sách nhà hàng theo ownerId và state = 1
      ref = FirebaseFirestore.instance
          .collection('restaurants')
          .where('ownerId', isEqualTo: userId)
          .where('state', isEqualTo: 1);
    } else {
      //hien thi khong co du lieu
      if (kDebugMode) {
        print("Không có dữ liệu");
      }
    }
  }

  void navigateToManageRestaurantPage(
      String restaurantId, String restaurantName) {
    // Chuyển hướng đến trang quản lý nhà hàng với restaurantId
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantOwnerManagementView(
          restaurantId: restaurantId,
          restaurantName: restaurantName,
        ),
      ),
    );
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
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Không có nhà hàng nào."));
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Đã xảy ra lỗi!"));
          }

          final restaurants = snapshot.data!.docs;

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurantData = restaurants[index];
              final restaurantId = restaurantData.id;
              final data = restaurantData.data()
                  as DocumentSnapshot<Map<String, dynamic>>;

              final restaurant = RestaurantModel.fromFirestore(data);

              final restaurantName =
                  restaurant.name.isNotEmpty ? restaurant.name : "Chưa có tên";
              final restaurantAddress = getAddressFromGeopoint(GeoPoint(
                  restaurant.location.latitude, restaurant.location.longitude));

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  onTap: () => navigateToManageRestaurantPage(
                      restaurantId, restaurantName),
                  title: Text(
                    restaurantName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(restaurantAddress as String),
                  trailing: const Text(
                    "Thay đổi >",
                    style: TextStyle(color: Colors.blue),
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
