import 'package:flutter/material.dart';
import 'package:table_order/src/model/restaurant_model.dart';
import 'package:table_order/src/services/firebase_review_services.dart';
import 'package:table_order/src/views/restaurant_view/restaurant_item_details_view.dart';

Widget restaurantCard(
    BuildContext context, RestaurantModel restaurant, double distance) {
  FirebaseReviewServices firebaseReviewServices = FirebaseReviewServices();
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
                StreamBuilder<double>(
                  stream: firebaseReviewServices.getAverageRatingStream(restaurant.restaurantId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return const Icon(Icons.error, color: Colors.red);
                    }
                    final averageRating = snapshot.data ?? 0.0;
                    return Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(averageRating.toStringAsFixed(1)),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}