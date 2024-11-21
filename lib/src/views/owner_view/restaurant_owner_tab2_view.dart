import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/restaurant.dart';

class RestaurantOwnerTab2View extends StatefulWidget {
  const RestaurantOwnerTab2View({super.key});

  @override
  State<StatefulWidget> createState() => _RestaurantOwnerTab2ViewState();
}

class _RestaurantOwnerTab2ViewState extends State<RestaurantOwnerTab2View> {
  late final Query ref;

  @override
  @override
  void initState() {
    super.initState();
    // Lấy thông tin userId của người dùng hiện tại
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      // Lọc các nhà hàng theo ownerId trùng với userId hiện tại
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
                Navigator.of(context).pop(); // Đóng dialog mà không làm gì
              },
              child: const Text("Huỷ"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                _removeRestaurant(id); // Thực thi xoá
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

  void _removeRestaurant(String id) {
    ref.ref.child(id).remove(); // ref.ref để trỏ đến DatabaseReference gốc
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xoá nhà hàng')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FirebaseAnimatedList(
        query: ref,
        itemBuilder: (BuildContext context, DataSnapshot snapshot,
            Animation<double> animation, int index) {
          final restaurant = Restaurant.fromSnapshot(snapshot);

          final createdAt = DateFormat('dd/MM/yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(restaurant.createdAt),
          );

          // Định nghĩa trạng thái và màu sắc
          String statusText;
          Color statusColor;

          switch (restaurant.type) {
            case '0':
              statusText = 'Chờ duyệt';
              statusColor = Colors.yellow;
              break;
            case '1':
              statusText = 'Đã duyệt';
              statusColor = Colors.green;
              break;
            case '2':
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              title: Text(restaurant.restaurantName), // Tên nhà hàng
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${restaurant.restaurantDistrict}, ${restaurant.restaurantCity}'), // Địa chỉ nhà hàng
                  Text('Ngày tạo: $createdAt'), // Hiển thị ngày tạo
                ],
              ),
              trailing: restaurant.type == '0'
                  ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmRemoveRestaurant(snapshot.key!),
              )
                  : null, // Không hiển thị nút với type khác 0
            ),
          );
        },
      ),
    );
  }
}
