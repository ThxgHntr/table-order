import 'dart:io';

String getFileNameToSave(String restaurantId, File image) {
  final fileName =
      '${restaurantId}_${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
  return 'restaurant_pictures/$restaurantId/$fileName';
}

String getReviewsStoragePath(String restaurantId, String reviewId, String image) {
  return 'restaurant_pictures/$restaurantId/review_images/$reviewId/$image';
}
