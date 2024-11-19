import 'package:firebase_database/firebase_database.dart';

import '../model/restaurant.dart';

class FirebaseRestaurantsServices {
  // Hàm lưu thông tin nhà hàng vào Firebase
  Future<bool> saveRestaurantInfo(Restaurant restaurant) async {
    try {
      final ref = FirebaseDatabase.instance.ref().child('restaurants').push();
      await ref.set(restaurant.toMap());
      return true; // Trả về true nếu lưu thành công
    } catch (e) {
      print('Error saving data: $e');
      return false; // Trả về false nếu có lỗi
    }
  }

}
