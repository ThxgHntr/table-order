import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

String getFileNameToSave(String restaurantId, File image) {
  final fileName =
      '${restaurantId}_${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
  return 'restaurant_pictures/$restaurantId/$fileName';
}

Future<String?> getDownloadUrl(String path) async {
  try {
    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child(path);
    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    return null;
  }
}
