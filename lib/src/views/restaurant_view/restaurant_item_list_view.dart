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
  int _nearbyLimit = 6;
  int _allLimit = 6;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late Query<Map<String, dynamic>> restaurantRef;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() async {
      restaurantRef =
          firestore.collection('restaurants').where('state', isEqualTo: 1);
      _nearbyLimit = 6;
      _allLimit = 6;
      currentLocation = await getGeopointFromCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nhà hàng gần bạn',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: restaurantRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Đã xảy ra lỗi!"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Không có nhà hàng nào gần bạn."));
          }

          final restaurants = snapshot.data!.docs;

          return FutureBuilder(
            future: currentLocation != null
                ? getAddressFromGeopoint(currentLocation!)
                : Future.value(null),
            builder: (context, userLocationSnapshot) {
              if (userLocationSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              List<Map<String, dynamic>> restaurantList = [];
              List<Map<String, dynamic>> nearbyRestaurants = [];

              for (var restaurantData in restaurants) {
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

                restaurantList.add({
                  'restaurant': restaurant,
                  'distance': distance,
                });

                if (distance <= 50) {
                  nearbyRestaurants.add({
                    'restaurant': restaurant,
                    'distance': distance,
                  });
                }
              }

              // Sort all restaurants by distance
              restaurantList
                  .sort((a, b) => a['distance'].compareTo(b['distance']));

              return SingleChildScrollView(
                child: Column(
                  children: [
                    if (nearbyRestaurants.isEmpty)
                      const Center(
                          child: Text("Không có nhà hàng nào gần bạn.")),
                    if (nearbyRestaurants.isNotEmpty)
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
                            itemCount: _nearbyLimit < nearbyRestaurants.length
                                ? _nearbyLimit
                                : nearbyRestaurants.length,
                            itemBuilder: (context, index) {
                              final restaurantData = nearbyRestaurants[index];
                              final restaurant = restaurantData['restaurant']
                                  as RestaurantModel;
                              final distance =
                                  restaurantData['distance'] as double;
                              final imageUrl =
                                  Future.value(restaurant.photos.first);

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
                                        builder: (context) =>
                                            RestaurantItemDetailsView(
                                          restaurantId: restaurant.restaurantId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: FutureBuilder<String>(
                                          future: imageUrl,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }

                                            if (snapshot.hasError ||
                                                !snapshot.hasData) {
                                              return const Icon(
                                                  Icons.broken_image);
                                            }

                                            final image = snapshot.data!;
                                            return ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                      top:
                                                          Radius.circular(8.0)),
                                              child: image.startsWith('http')
                                                  ? Image.network(
                                                      image,
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          const Icon(Icons
                                                              .broken_image),
                                                    )
                                                  : Image.file(
                                                      File(image),
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          const Icon(Icons
                                                              .broken_image),
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on,
                                                    size: 16),
                                                SizedBox(width: 4),
                                                Text((distance < 1
                                                    ? '${(distance * 1000).toStringAsFixed(0)}m'
                                                    : '${distance.toStringAsFixed(1)} km')),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.star,
                                                    size: 16,
                                                    color: Colors.yellow),
                                                Text(restaurant.rating
                                                    .toString()),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          if (_nearbyLimit < nearbyRestaurants.length)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _nearbyLimit += 6;
                                });
                              },
                              child: Text('Xem thêm'),
                            ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    Text(
                      'Tất cả nhà hàng',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                      itemCount: _allLimit < restaurantList.length
                          ? _allLimit
                          : restaurantList.length,
                      itemBuilder: (context, index) {
                        final restaurantData = restaurantList[index];
                        final restaurant =
                            restaurantData['restaurant'] as RestaurantModel;
                        final distance = restaurantData['distance'] as double;
                        final imageUrl = Future.value(restaurant.photos.first);

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
                                  builder: (context) =>
                                      RestaurantItemDetailsView(
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
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }

                                      if (snapshot.hasError ||
                                          !snapshot.hasData) {
                                        return const Icon(Icons.broken_image);
                                      }

                                      final image = snapshot.data!;
                                      return ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(8.0)),
                                        child: image.startsWith('http')
                                            ? Image.network(
                                                image,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const Icon(
                                                        Icons.broken_image),
                                              )
                                            : Image.file(
                                                File(image),
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const Icon(
                                                        Icons.broken_image),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 16),
                                          SizedBox(width: 4),
                                          Text((distance < 1
                                              ? '${(distance * 1000).toStringAsFixed(0)}m'
                                              : '${distance.toStringAsFixed(1)} km')),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              size: 16, color: Colors.yellow),
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
                      },
                    ),
                    if (_allLimit < restaurantList.length)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _allLimit += 6;
                          });
                        },
                        child: Text('Xem thêm'),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
