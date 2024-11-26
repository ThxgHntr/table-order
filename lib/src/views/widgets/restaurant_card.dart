import 'package:flutter/material.dart';
import 'package:table_order/src/model/restaurant_model.dart';
import 'package:table_order/src/views/restaurant_view/restaurant_item_details_view.dart';

Widget restaurantCard(
    BuildContext context, RestaurantModel restaurant, double distance) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    elevation: 3,
    child: InkWell(
      borderRadius: BorderRadius.circular(8.0),
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
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8.0)),
              child: Image.network(
                restaurant.photos[0],
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, size: 100),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              restaurant.name,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
