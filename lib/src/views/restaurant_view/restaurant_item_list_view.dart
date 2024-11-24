import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:table_order/src/views/restaurant_view/restaurant_item_details_view.dart';
import '../../model/restaurant_model.dart';
import 'dart:io';

import '../../utils/location_helper.dart';

class RestaurantItemListView extends StatefulWidget {
  static const routeName = '/';

  const RestaurantItemListView({super.key});

  @override
  State<StatefulWidget> createState() => RestaurantItemListViewState();
}

class RestaurantItemListViewState extends State<RestaurantItemListView> {
  GeoPoint? currentLocation;
  final int _pageSize = 6;
  DocumentSnapshot? _lastNearbyDocument;
  DocumentSnapshot? _lastAllDocument;
  bool _isLoadingMoreNearby = false;
  bool _isLoadingMoreAll = false;
  bool _hasMoreNearbyData = true;
  bool _hasMoreAllData = true;
  bool _isLoadingLocation = true;
  final List<Map<String, dynamic>> _restaurantList = [];
  final List<Map<String, dynamic>> _nearbyRestaurants = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _getCurrentLocation();
    _loadNearbyRestaurants();
    _loadAllRestaurants();
  }

  Future<void> _getCurrentLocation() async {
    final location = await getGeopointFromCurrentLocation();
    setState(() {
      currentLocation = location;
      _isLoadingLocation = false;
    });
  }

  Future<void> _loadNearbyRestaurants() async {
    if (_isLoadingMoreNearby || !_hasMoreNearbyData || _isLoadingLocation)
      return;
    setState(() {
      _isLoadingMoreNearby = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('restaurants')
        .where('state', isEqualTo: 1)
        .limit(_pageSize);

    if (_lastNearbyDocument != null) {
      query = query.startAfterDocument(_lastNearbyDocument!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _lastNearbyDocument = snapshot.docs.last;
      _hasMoreNearbyData = snapshot.docs.length == _pageSize;

      for (var restaurantData in snapshot.docs) {
        final restaurant = RestaurantModel.fromFirestore(
            restaurantData as DocumentSnapshot<Map<String, dynamic>>);
        final restaurantLocation = restaurant.location;
        double distance = 0.0;

        if (currentLocation != null) {
          distance = Geolocator.distanceBetween(
                currentLocation!.latitude,
                currentLocation!.longitude,
                restaurantLocation.latitude,
                restaurantLocation.longitude,
              ) /
              1000; // Convert to kilometers
        }

        if (distance <= 50) {
          _nearbyRestaurants.add({
            'restaurant': restaurant,
            'distance': distance,
          });
        }
      }

      // Sort nearby restaurants by distance
      _nearbyRestaurants.sort((a, b) => a['distance'].compareTo(b['distance']));
    } else {
      _hasMoreNearbyData = false;
    }

    setState(() {
      _isLoadingMoreNearby = false;
    });
  }

  Future<void> _loadAllRestaurants() async {
    if (_isLoadingMoreAll || !_hasMoreAllData || _isLoadingLocation) return;
    setState(() {
      _isLoadingMoreAll = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('restaurants')
        .where('state', isEqualTo: 1)
        .limit(_pageSize);

    if (_lastAllDocument != null) {
      query = query.startAfterDocument(_lastAllDocument!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _lastAllDocument = snapshot.docs.last;
      _hasMoreAllData = snapshot.docs.length == _pageSize;

      for (var restaurantData in snapshot.docs) {
        final restaurant = RestaurantModel.fromFirestore(
            restaurantData as DocumentSnapshot<Map<String, dynamic>>);
        final restaurantLocation = restaurant.location;
        double distance = 0.0;

        if (currentLocation != null) {
          distance = Geolocator.distanceBetween(
                currentLocation!.latitude,
                currentLocation!.longitude,
                restaurantLocation.latitude,
                restaurantLocation.longitude,
              ) /
              1000; // Convert to kilometers
        }

        _restaurantList.add({
          'restaurant': restaurant,
          'distance': distance,
        });
      }

      // Sort all restaurants by distance
      _restaurantList.sort((a, b) => a['distance'].compareTo(b['distance']));
    } else {
      _hasMoreAllData = false;
    }

    setState(() {
      _isLoadingMoreAll = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Danh sách nhà hàng',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _isLoadingLocation
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Nhà hàng gần bạn',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (_nearbyRestaurants.isEmpty)
                    const Center(child: Text("Không có nhà hàng nào gần bạn.")),
                  if (_nearbyRestaurants.isNotEmpty)
                    Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(10),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 3 / 4,
                          ),
                          itemCount: _nearbyRestaurants.length,
                          itemBuilder: (context, index) {
                            final restaurantData = _nearbyRestaurants[index];
                            final restaurant =
                                restaurantData['restaurant'] as RestaurantModel;
                            final distance =
                                restaurantData['distance'] as double;
                            final imageUrl =
                                Future.value(restaurant.photos.first);

                            return _buildRestaurantCard(
                                restaurant, distance, imageUrl);
                          },
                        ),
                        if (_hasMoreNearbyData)
                          TextButton(
                            onPressed: _loadNearbyRestaurants,
                            child: _isLoadingMoreNearby
                                ? const CircularProgressIndicator()
                                : const Text('Xem thêm'),
                          ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Text(
                    'Tất cả nhà hàng',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 3 / 4,
                    ),
                    itemCount: _restaurantList.length,
                    itemBuilder: (context, index) {
                      final restaurantData = _restaurantList[index];
                      final restaurant =
                          restaurantData['restaurant'] as RestaurantModel;
                      final distance = restaurantData['distance'] as double;
                      final imageUrl = Future.value(restaurant.photos.first);

                      return _buildRestaurantCard(
                          restaurant, distance, imageUrl);
                    },
                  ),
                  if (_hasMoreAllData)
                    TextButton(
                      onPressed: _loadAllRestaurants,
                      child: _isLoadingMoreAll
                          ? const CircularProgressIndicator()
                          : const Text('Xem thêm'),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildRestaurantCard(
      RestaurantModel restaurant, double distance, Future<String> imageUrl) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 5,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantItemDetailsView(
                restaurantId: restaurant.restaurantId,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<String>(
                future: imageUrl,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Icon(Icons.broken_image);
                  }

                  final image = snapshot.data!;
                  return ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8.0)),
                    child: image.startsWith('http')
                        ? Image.network(
                            image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                          )
                        : Image.file(
                            File(image),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                          ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                restaurant.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      SizedBox(width: 4),
                      Text((distance < 1
                          ? '${(distance * 1000).toStringAsFixed(0)}m'
                          : '${distance.toStringAsFixed(1)} km')),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.yellow),
                      Text(restaurant.rating.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
