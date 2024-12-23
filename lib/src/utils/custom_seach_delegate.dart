import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:table_order/src/model/restaurant_model.dart';
import 'package:table_order/src/views/restaurant_view/restaurant_item_details_view.dart';

class CustomSeachDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchRestaurants(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No results found'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final restaurantData = snapshot.data![index];
              final restaurant = restaurantData['restaurant'] as RestaurantModel;
              final distance = restaurantData['distance'] as double;

              return ListTile(
                leading: Image.network(
                  restaurant.photos.isNotEmpty ? restaurant.photos[0] : '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(restaurant.name),
                subtitle: Row(
                  children: [
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < restaurant.rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.yellow,
                          size: 16,
                        );
                      }),
                    ),
                    const SizedBox(width: 5),
                    Text('${distance.toStringAsFixed(1)} km'),
                  ],
                ),
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
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchRestaurants(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No suggestions found'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final restaurantData = snapshot.data![index];
              final restaurant = restaurantData['restaurant'] as RestaurantModel;
              final distance = restaurantData['distance'] as double;

              return ListTile(
                leading: Image.network(
                  restaurant.photos.isNotEmpty ? restaurant.photos[0] : '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(restaurant.name),
                subtitle: Row(
                  children: [
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < restaurant.rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.yellow,
                          size: 16,
                        );
                      }),
                    ),
                    const SizedBox(width: 5),
                    Text('${distance.toStringAsFixed(1)} km'),
                  ],
                ),
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
              );
            },
          );
        }
      },
    );
  }

  String removeDiacritics(String str) {
    final withDiacritics = 'áàảãạăắằẳẵặâấầẩẫậéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵđ';
    final withoutDiacritics = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    for (int i = 0; i < withDiacritics.length; i++) {
      str = str.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return str;
  }

  Future<List<Map<String, dynamic>>> _searchRestaurants(String query) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .limit(10) // Limit the number of results
        .get();

    final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final lowerCaseQuery = removeDiacritics(query.toLowerCase());

    return snapshot.docs.map((doc) {
      final restaurant = RestaurantModel.fromFirestore(doc);
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        restaurant.location.latitude,
        restaurant.location.longitude,
      ) / 1000; // Convert to kilometers

      if (removeDiacritics(restaurant.name.toLowerCase()).contains(lowerCaseQuery)) {
        return {
          'restaurant': restaurant,
          'distance': distance,
        };
      } else {
        return null;
      }
    }).where((element) => element != null).cast<Map<String, dynamic>>().toList();
  }
}