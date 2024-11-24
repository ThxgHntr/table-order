import 'dart:io';

String getFileName(String restaurantId, File image) {
  final fileName =
      '${restaurantId}_${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
  return 'restaurant_pictures/$restaurantId/$fileName';
}
