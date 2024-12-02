import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_order/src/views/restaurant_view/restaurant_review_view.dart';
import 'package:table_order/src/model/restaurant_model.dart';
import '../../utils/location_helper.dart';

class RestaurantItemDetailsView extends StatefulWidget {
  final String restaurantId;

  const RestaurantItemDetailsView({super.key, required this.restaurantId});

  static const routeName = '/item-details';

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
      List<String> openDates, String? openTime, String? closeTime) {
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
      return '$openTime - $closeTime';
    } else {
      return 'Closed';
    }
  }

  String getPriceRangeString(int lowestPrice, int highestPrice) {
    return '$lowestPrice - $highestPrice VND';
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
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 800),
                child: _buildRestaurantDetails(snapshot.data!),
              ),
            );
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
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add reservation functionality
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // this color C64027
                  backgroundColor: Color(0xFFC64027),
                ),
                child: const Text(
                  'Đặt chỗ ngay',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(RestaurantModel restaurantData) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: _cardDecoration(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              restaurantData.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              softWrap: true,
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border,
                      color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    // Favorite button functionality
                  },
                ),
                IconButton(
                  icon: Icon(Icons.share,
                      color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    // Share functionality
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(RestaurantModel restaurantData) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.description, 'Mô tả', restaurantData.description),
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
            getTodayOpenCloseTimes(restaurantData.openDates,
                restaurantData.openTime, restaurantData.closeTime),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.attach_money,
            'Giá cả',
            getPriceRangeString(
                restaurantData.lowestPrice, restaurantData.highestPrice),
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
      decoration: _cardDecoration(context),
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
                size: 25, // Increased size
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
    final List<String> photos = List<String>.from(restaurantData.photos);

    return CarouselSlider(
      items: photos
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
        height: 200.0,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 25, color: Theme.of(context).iconTheme.color),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                content,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(8), // Add rounded corners
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2), // Reduce shadow opacity
          blurRadius: 3, // Reduce blur radius
          offset: const Offset(0, 2), // Reduce offset
        ),
      ],
    );
  }
}
