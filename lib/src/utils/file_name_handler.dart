import 'dart:io';

String getFileNameToSave(String restaurantId, File image) {
  final fileName =
      '${restaurantId}_${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
  return 'restaurant_pictures/$restaurantId/$fileName';
}

String getFileNameToSaveToFirestore(String restaurantId, File image) {
  final fileName = getFileNameToSave(restaurantId, image);
  return 'gs://mangaapp-d064a.appspot.com/restaurant_pictures/$fileName';
}
