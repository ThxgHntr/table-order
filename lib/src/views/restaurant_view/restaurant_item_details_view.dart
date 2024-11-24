import 'dart:ffi';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_order/src/views/restaurant_view/restaurant_review_view.dart';
import 'package:table_order/src/model/restaurant_model.dart';

class RestaurantItemDetailsView extends StatefulWidget {
  final String restaurantId;

  const RestaurantItemDetailsView({super.key, required this.restaurantId});

  static const routeName = '/sample_item';

  @override
  State<RestaurantItemDetailsView> createState() =>
      _RestaurantItemDetailsViewState();
}

class _RestaurantItemDetailsViewState extends State<RestaurantItemDetailsView> {
  late Future<RestaurantModel> restaurantData;

  @override
  void initState() {
    super.initState();
    restaurantData = _fetchRestaurantData();
  }

  Future<RestaurantModel> _fetchRestaurantData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .get();

      if (snapshot.exists) {
        final restaurant = RestaurantModel.fromFirestore(snapshot);
        // Print all restaurant details
        print('Restaurant Data:');
        print('Name: ${restaurant.name}');
        print('Description: ${restaurant.description}');
        print('Location: ${restaurant.location}');
        print('Price Range: ${restaurant.priceRange}');
        print('Rating: ${restaurant.rating}');
        print('Open Dates: ${restaurant.openDates}');
        print('Open Times: ${restaurant.openTime}');
        print('Dishes Style: ${restaurant.dishesStyle}');
        print('Floors: ${restaurant.floors}');
        print('Photos: ${restaurant.photos}');
        print('Rating: ${restaurant.rating}');
        print('Price Range: ${restaurant.priceRange.toString()}');
        return restaurant;
      } else {
        throw Exception("Restaurant not found");
      }
    } catch (e) {
      throw Exception("Error fetching restaurant data: $e");
    }
  }

  String getTodayOpenCloseTimes(
      List<String> openDates, Map<String, dynamic> openTime) {
    final today = DateTime.now().weekday;
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final todayKey = days[today - 1];

    if (openDates.contains(todayKey)) {
      return '${openTime['open'] ?? 'N/A'} - ${openTime['close'] ?? 'N/A'}';
    } else {
      return 'Closed';
    }
  }

  String getPriceRangeString(PriceRange priceRange) {
    return '${priceRange.lowest} - ${priceRange.highest} VND';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin nhà hàng'),
      ),
      body: FutureBuilder<RestaurantModel>(
        future: restaurantData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final restaurant = snapshot.data!;
            return _buildRestaurantDetails(restaurant);
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildRestaurantDetails(RestaurantModel restaurantData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Image Carousel
          const SizedBox(height: 10),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: _buildImageCarousel(restaurantData),
          ),
          const SizedBox(height: 15),

          // Restaurant Name | Heart Button | Share Button
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  restaurantData.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {
                        // Add your favorite button functionality
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        // Add your share functionality
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // Restaurant Details Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                    Icons.description, 'Mô tả', restaurantData.description),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.location_on, 'Địa chỉ',
                    restaurantData.location.toString()),
                const SizedBox(height: 10),
                _buildInfoRow(
                    Icons.access_time,
                    'Giờ mở cửa',
                    getTodayOpenCloseTimes(
                        restaurantData.openDates, restaurantData.openTime)),
                const SizedBox(height: 10),
              _buildInfoRow(Icons.attach_money, 'Giá cả',
                  getPriceRangeString(restaurantData.priceRange)),
              const SizedBox(height: 10),
                _buildInfoRow(Icons.restaurant_menu, 'Loại món ăn',
                    restaurantData.dishesStyle.join(' | ')),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.business, 'Số tầng',
                    restaurantData.floors.length.toString()),
                const SizedBox(height: 10),
                _buildInfoRow(
                    Icons.table_bar,
                    'Số bàn',
                    restaurantData.floors
                        .fold<int>(
                        0, (prev, floor) => prev + floor.tables.length)
                        .toString()),
              ],
            ),
          ),

          // Reviews Section
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                        (index) => Icon(
                      index < restaurantData.rating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.yellow,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantReviewView(
                          restaurantId: widget.restaurantId,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Xem tất cả các đánh giá',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),

          // Reservation Button
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Add your reservation button functionality
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Colors.green,
            ),
            child: const Text(
              'Đặt chỗ ngay',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, size: 25, color: Colors.blueGrey),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            '$label: $content',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel(RestaurantModel restaurantData) {
    return CarouselSlider(
      items: restaurantData.photos.map((photoPath) {
        return Builder(
          builder: (BuildContext context) {
            // Convert the local file path string to a File object
            File imageFile = File(photoPath);
            return Image.file(
              imageFile,
              fit: BoxFit.cover,
              width: double.infinity,
            );
          },
        );
      }).toList(),
      options: CarouselOptions(
        height: 200.0,
        enlargeCenterPage: true,
        viewportFraction: 1.0,
        autoPlay: true, // Enable auto play
        autoPlayInterval: Duration(seconds: 3), // Set the interval to 3 seconds
        onPageChanged: (index, reason) {
          setState(() {});
        },
      ),
    );
  }
}