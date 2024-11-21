import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_order/src/views/owner_view/restaurant_owner_management_view.dart';

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
      // Lọc danh sách nhà hàng theo ownerId và type = 1
      ref = FirebaseDatabase.instance
          .ref()
          .child("restaurants")
          .orderByChild("ownerID")
          .equalTo(userId);
    } else {
      //hien thi khong co du lieu
      if (kDebugMode) {
        print("Không có dữ liệu");
      }
    }
  }

  void navigateToManageRestaurantPage(String restaurantId, String restaurantName) {
    // Chuyển hướng đến trang quản lý nhà hàng với restaurantId
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantOwnerManagementView(restaurantId: restaurantId,
        restaurantName: restaurantName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Đã xảy ra lỗi!"));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Không có nhà hàng nào."));
          }

          final Map<dynamic, dynamic> restaurants =
          (snapshot.data!.snapshot.value as Map<dynamic, dynamic>)
              .map((key, value) => MapEntry(key, value))
              .cast<String, dynamic>();

          // Lọc các nhà hàng có type = 1
          final filteredRestaurants = restaurants.entries
              .where((entry) => entry.value['type'] == '1')
              .toList();

          if (filteredRestaurants.isEmpty) {
            return const Center(child: Text("Không có nhà hàng nào hợp lệ."));
          }

          return ListView.builder(
            itemCount: filteredRestaurants.length,
            itemBuilder: (context, index) {
              final entry = filteredRestaurants[index];
              final restaurantId = entry.key;
              final restaurantData = entry.value;

              final restaurantName = restaurantData['restaurantName'] ?? "Chưa có tên";
              final restaurantAddress =
                  "${restaurantData['restaurantDistrict'] ?? ''}, ${restaurantData['restaurantCity'] ?? ''}";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  onTap: () => navigateToManageRestaurantPage(restaurantId, restaurantName),
                  title: Text(
                    restaurantName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(restaurantAddress),
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