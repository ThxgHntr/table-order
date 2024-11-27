import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:table_order/src/views/widgets/restaurant_card.dart';
import '../../model/restaurant_model.dart';

import '../../utils/location_helper.dart';

class RestaurantItemListView extends StatefulWidget {
  static const routeName = '/';
  final int itemsPerPage;

  const RestaurantItemListView({super.key, this.itemsPerPage = 10});

  @override
  State<StatefulWidget> createState() => RestaurantItemListViewState();
}

class RestaurantItemListViewState extends State<RestaurantItemListView> {
  GeoPoint? currentLocationGeoPoint;
  late int _pageSize;
  DocumentSnapshot? _lastAllDocument;
  DocumentSnapshot? _lastNearbyDocument;
  bool _isLoadingMoreNearby = false;
  bool _isLoadingMoreAll = false;
  bool _hasMoreNearbyData = true;
  bool _hasMoreAllData = true;
  bool _isLoadingLocation = true;
  final List<Map<String, dynamic>> _restaurantList = [];
  final List<Map<String, dynamic>> _nearbyRestaurants = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initialize();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _getCurrentGeopoint();
    _updatePageSize();
    _loadRestaurants(isNearby: true);
    _loadRestaurants(isNearby: false);
  }

  void _updatePageSize() {
    final width = MediaQuery.of(context).size.width;
    final bool isLargeScreen = width > 800;
    setState(() {
      _pageSize = isLargeScreen ? 20 : widget.itemsPerPage;
    });
  }

  Future<void> _getCurrentGeopoint() async {
    final geopoint = await getGeopointFromCurrentLocation();
    setState(() {
      currentLocationGeoPoint = geopoint;
      _isLoadingLocation = false;
    });
  }

  Future<void> _loadRestaurants({required bool isNearby}) async {
    if ((isNearby && (_isLoadingMoreNearby || !_hasMoreNearbyData)) ||
        (!isNearby && (_isLoadingMoreAll || !_hasMoreAllData)) ||
        _isLoadingLocation) return;

    setState(() {
      if (isNearby) {
        _isLoadingMoreNearby = true;
      } else {
        _isLoadingMoreAll = true;
      }
    });

    Query query = FirebaseFirestore.instance
        .collection('restaurants')
        .where('state', isEqualTo: 1)
        .limit(_pageSize);

    if (isNearby && _lastNearbyDocument != null) {
      query = query.startAfterDocument(_lastNearbyDocument!);
    } else if (!isNearby && _lastAllDocument != null) {
      query = query.startAfterDocument(_lastAllDocument!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      if (isNearby) {
        _lastNearbyDocument = snapshot.docs.last;
        _hasMoreNearbyData = snapshot.docs.length == _pageSize;
      } else {
        _lastAllDocument = snapshot.docs.last;
        _hasMoreAllData = snapshot.docs.length == _pageSize;
      }

      for (var restaurantData in snapshot.docs) {
        final restaurant = RestaurantModel.fromFirestore(
            restaurantData as DocumentSnapshot<Map<String, dynamic>>);
        final restaurantLocation = restaurant.location;
        double distance = 0.0;

        if (currentLocationGeoPoint != null) {
          distance = Geolocator.distanceBetween(
                currentLocationGeoPoint!.latitude,
                currentLocationGeoPoint!.longitude,
                restaurantLocation.latitude,
                restaurantLocation.longitude,
              ) /
              1000; // Convert to kilometers
        }

        if (isNearby && distance <= 50) {
          _nearbyRestaurants.add({
            'restaurant': restaurant,
            'distance': distance,
          });
        } else if (!isNearby) {
          _restaurantList.add({
            'restaurant': restaurant,
            'distance': distance,
          });
        }
      }

      if (isNearby) {
        _nearbyRestaurants
            .sort((a, b) => a['distance'].compareTo(b['distance']));
      } else {
        _restaurantList.sort((a, b) => a['distance'].compareTo(b['distance']));
      }
    } else {
      if (isNearby) {
        _hasMoreNearbyData = false;
      } else {
        _hasMoreAllData = false;
      }
    }

    setState(() {
      if (isNearby) {
        _isLoadingMoreNearby = false;
      } else {
        _isLoadingMoreAll = false;
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMoreNearbyData) {
        _loadRestaurants(isNearby: true);
      } else if (_hasMoreAllData) {
        _loadRestaurants(isNearby: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isSmallScreen = width < 600;
    final bool isLargeScreen = width > 800;
    final int crossAxisCount = isSmallScreen
        ? 2
        : isLargeScreen
            ? 3
            : 3;
    final double childAspectRatio = isSmallScreen ? 3 / 4 : 4 / 3;
    final double sidePadding = isLargeScreen ? 20.0 : 10.0;

    return Scaffold(
      body: _isLoadingLocation
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: sidePadding),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Nhà hàng gần bạn',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.left, // Align text to the left
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
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemCount: _nearbyRestaurants.length,
                          itemBuilder: (context, index) {
                            final restaurantData = _nearbyRestaurants[index];
                            final restaurant =
                                restaurantData['restaurant'] as RestaurantModel;
                            final distance =
                                restaurantData['distance'] as double;

                            return restaurantCard(
                                context, restaurant, distance);
                          },
                        ),
                        if (_hasMoreNearbyData && !isLargeScreen)
                          TextButton(
                            onPressed: () => _loadRestaurants(isNearby: true),
                            child: _isLoadingMoreNearby
                                ? const CircularProgressIndicator()
                                : const Text('Xem thêm'),
                          ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tất cả nhà hàng',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.left, // Align text to the left
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: _restaurantList.length,
                    itemBuilder: (context, index) {
                      final restaurantData = _restaurantList[index];
                      final restaurant =
                          restaurantData['restaurant'] as RestaurantModel;
                      final distance = restaurantData['distance'] as double;

                      return restaurantCard(context, restaurant, distance);
                    },
                  ),
                  if (_hasMoreAllData && !isLargeScreen)
                    TextButton(
                      onPressed: () => _loadRestaurants(isNearby: false),
                      child: _isLoadingMoreAll
                          ? const CircularProgressIndicator()
                          : const Text('Xem thêm'),
                    ),
                ],
              ),
            ),
    );
  }
}
