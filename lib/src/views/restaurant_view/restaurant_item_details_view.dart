import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:table_order/src/views/restaurant_view/restaurant_review_view.dart';

class RestaurantItemDetailsView extends StatefulWidget {
  final String restaurantId;

  const RestaurantItemDetailsView({super.key, required this.restaurantId});

  static const routeName = '/sample_item';

  @override
  State<RestaurantItemDetailsView> createState() => _RestaurantItemDetailsViewState();
}

class _RestaurantItemDetailsViewState extends State<RestaurantItemDetailsView> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Map<String, dynamic> restaurantData = {};
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _fetchRestaurantData();
  }

  Future<void> _fetchRestaurantData() async {
    try {
      if (kDebugMode) {
        print('restaurantId: ${widget.restaurantId}');
      }
      final snapshot = await _dbRef.child('restaurants/${widget.restaurantId}').once();
      if (snapshot.snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        setState(() {
          restaurantData = {
            ...data,
            'address': '${data['restaurantStreet']}, ${data['restaurantDistrict']}, ${data['restaurantCity']}',
          };
        });
      }
    } catch (e) {
      debugPrint("Error fetching restaurant data: $e");
    }
  }

  // Get open/close times for today
  String getTodayOpenCloseTimes() {
    final today = DateTime.now().weekday;
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final todayKey = days[today - 1];  // Get the name of the current day (e.g., "Monday")

    final openCloseTimes = restaurantData['openCloseTimes'] ?? {};
    if (openCloseTimes.containsKey(todayKey)) {
      return '${openCloseTimes[todayKey]?['open'] ?? 'N/A'} - ${openCloseTimes[todayKey]?['close'] ?? 'N/A'}';
    } else {
      return 'Closed';
    }
  }

  // Get the number of floors in the restaurant
  int getFloorCount() {
    final floors = restaurantData['floors'] ?? {};
    return floors.length;
  }

  // Get the total number of tables in the restaurant
  int getTotalTables() {
    final floors = restaurantData['floors'] ?? {}; // Ensure 'floors' is a Map
    int totalTables = 0;

    // Iterate over each floor
    floors.forEach((key, value) {
      // Check if 'tables' is a Map and safely count the number of tables
      if (value['tables'] is Map) {
        totalTables += (value['tables'] as Map).length;  // Safely cast 'tables' as a Map and get its length
      }
    });

    return totalTables;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin nhà hàng'),
        shape: const Border(
          bottom: BorderSide(
            color: Colors.deepOrange,
            width: 1,
          ),
        ),
      ),
      body: restaurantData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildRestaurantDetails(),
    );
  }

  Widget _buildRestaurantDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Section 1: Image Carousel (Rectangular)
          const SizedBox(height: 10),
          Container(
            height: 200,  // Adjust height as needed
            decoration: BoxDecoration(
              color: Colors.white, // Background color for the image carousel section
              borderRadius: BorderRadius.circular(0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // Shadow position
                ),
              ],
            ),
            child: _buildImageCarousel(),
          ),
          const SizedBox(height: 15),

          // Section 2: Restaurant Name | Heart Button | Share Button (Rectangular)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 0),  // Added margin for spacing
            decoration: BoxDecoration(
              color: Colors.white, // Light background color for this section
              borderRadius: BorderRadius.circular(0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // Shadow position
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Restaurant Name
                Text(
                  restaurantData['restaurantName'] ?? 'Restaurant Name',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    // Heart Icon for Favorite
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {
                        // Add your favorite button functionality
                      },
                    ),
                    // Share Icon
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

          // Section 3: Combined Info Card for Restaurant Details
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 0),  // Added margin for spacing
            decoration: BoxDecoration(
              color: Colors.white,  // White background for the info card
              borderRadius: BorderRadius.circular(0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2), // Shadow position
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description Section
                _buildInfoRow(Icons.description, 'Mô tả', restaurantData['restaurantDescription'] ?? 'N/A'),
                const SizedBox(height: 10),
                // Address
                _buildInfoRow(Icons.location_on, 'Địa chỉ', restaurantData['address'] ?? 'N/A'),
                const SizedBox(height: 10),
                // Hours
                _buildInfoRow(Icons.access_time, 'Giờ mở cửa', getTodayOpenCloseTimes()),
                const SizedBox(height: 10),
                // Price Range
                _buildInfoRow(Icons.attach_money, 'Giá cả', restaurantData['priceRange'] ?? 'N/A'),
                const SizedBox(height: 10),
                // Dishes
                _buildInfoRow(Icons.restaurant_menu, 'Loại món ăn', restaurantData['selectedKeywords']?.join(' | ') ?? 'N/A'),
                const SizedBox(height: 10),
                // Floors
                _buildInfoRow(Icons.business, 'Số tầng', getFloorCount().toString()),
                const SizedBox(height: 10),
                // Tables
                _buildInfoRow(Icons.table_bar, 'Số bàn', getTotalTables().toString()),
              ],
            ),
          ),

          // Section 4: Reviews Section (Star Rating + View All Reviews)
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 0),  // Added margin for spacing
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
                // Star Rating (Fake data, replace with actual rating)
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 20),
                    Icon(Icons.star, color: Colors.yellow, size: 20),
                    Icon(Icons.star, color: Colors.yellow, size: 20),
                    Icon(Icons.star, color: Colors.yellow, size: 20),
                    Icon(Icons.star_border, color: Colors.yellow, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      '4.0 / 5.0 (120 đánh giá)',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // View All Reviews Button
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

          // Section 5: Reservation Button (at the bottom)
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
              backgroundColor: Colors.green,  // Button color
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
        Icon(icon, size: 25, color: Colors.blueGrey), // Icon
        const SizedBox(width: 15),
        Expanded(
          child: Row(  // Use Row instead of Column to align label and content horizontally
            mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Space between label and content
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                content,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    final List<String> imgList = List<String>.from(restaurantData['selectedImage'] ?? []);
    return Column(
      children: [
        CarouselSlider(
          items: imgList
              .map(
                (item) => Center(
              child: Image.network(
                item,
                fit: BoxFit.cover,
                width: 1000,
              ),
            ),
          )
              .toList(),
          options: CarouselOptions(
            height: 170,
            aspectRatio: 16 / 9,
            viewportFraction: 0.8,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imgList.map((url) {
            int index = imgList.indexOf(url);
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _current == index
                    ? const Color.fromRGBO(0, 0, 0, 0.9)
                    : const Color.fromRGBO(0, 0, 0, 0.4),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
