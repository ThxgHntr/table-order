import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_order/src/views/restaurant_view/restaurant_review_view.dart';
import 'package:table_order/src/model/restaurant_model.dart';
import '../../utils/location_helper.dart';

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
        return RestaurantModel.fromFirestore(snapshot);
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
            return _buildRestaurantDetails(snapshot.data!);
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
          const SizedBox(height: 10),
          _buildImageCarousel(restaurantData),
          const SizedBox(height: 15),
          _buildHeader(restaurantData),
          const SizedBox(height: 15),
          _buildDetailsCard(restaurantData),
          const SizedBox(height: 10),
          _buildReviewsSection(restaurantData),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Add reservation functionality
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

  Widget _buildHeader(RestaurantModel restaurantData) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            restaurantData.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // Favorite button functionality
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // Share functionality
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(RestaurantModel restaurantData) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
              Icons.description, 'Mô tả', restaurantData.description),
          const SizedBox(height: 10),
          FutureBuilder<String>(
            future: getAddressFromGeopoint(restaurantData.location),
            builder: (context, snapshot) {
              return _buildInfoRow(
                Icons.location_on,
                'Địa chỉ',
                snapshot.data ?? 'Đang tải...',
              );
            },
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.access_time,
            'Giờ mở cửa',
            getTodayOpenCloseTimes(
                restaurantData.openDates, restaurantData.openTime),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.attach_money,
            'Giá cả',
            getPriceRangeString(restaurantData.priceRange),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.restaurant_menu,
            'Loại món ăn',
            restaurantData.dishesStyle.join(' | '),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(RestaurantModel restaurantData) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: _cardDecoration(),
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
                  builder: (context) =>
                      RestaurantReviewView(restaurantId: widget.restaurantId),
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
    );
  }

  Widget _buildImageCarousel(RestaurantModel restaurantData) {
    return CarouselSlider(
      items: restaurantData.photos.map((photoPath) {
        return Image.file(
          File(photoPath),
          fit: BoxFit.cover,
          width: double.infinity,
        );
      }).toList(),
      options: CarouselOptions(
        height: 200.0,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String content) {
    return Row(
      children: [
        Icon(icon, size: 25, color: Colors.blueGrey),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            '$label: $content',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
