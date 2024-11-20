import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/restaurant.dart';
import '../../services/firebase_restaurants_services.dart';

class RestaurantOwnerTab2View extends StatefulWidget {
  const RestaurantOwnerTab2View({super.key});

  @override
  State<StatefulWidget> createState() => _RestaurantOwnerTab2ViewState();
}

class _RestaurantOwnerTab2ViewState extends State<RestaurantOwnerTab2View> {
  final FirebaseRestaurantsServices _restaurantServices = FirebaseRestaurantsServices();
  late Future<List<Restaurant>> _restaurantsFuture;

  @override
  void initState() {
    super.initState();
    _restaurantsFuture = _restaurantServices.getRestaurantsByType('0'); // Giả sử '0' là loại "Chờ duyệt"
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Restaurant>>(
      future: _restaurantsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final restaurants = snapshot.data!;
          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              // Chuyển timestamp 'createdAt' thành định dạng ngày tháng
              final createdAt = DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(restaurant.createdAt));

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.yellow, // Màu vàng cho trạng thái chờ duyệt
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Chờ duyệt', // Trạng thái chờ duyệt
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  title: Text(restaurant.restaurantName), // Tên nhà hàng
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${restaurant.restaurantDistrict}, ${restaurant.restaurantCity}'), // Địa chỉ nhà hàng
                      Text('Ngày tạo: $createdAt'), // Hiển thị ngày tạo
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No restaurants found.'));
        }
      },
    );
  }
}
