import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../model/restaurant.dart';

class FirebaseRestaurantsServices {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Upload image to Firebase Storage with restaurantId in the path
  Future<String?> uploadImageToFirebaseStorage(String restaurantId, File image) async {
    try {
      final fileName = '${restaurantId}_${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
      final ref = _storage.ref().child('restaurant_pictures/$restaurantId/$fileName');
      final uploadTask = ref.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      if (kDebugMode) {
        print('Image uploaded successfully: $downloadUrl');
      }
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image to Firebase Storage: $e');
      }
      return null;
    }
  }

  // Upload multiple images with restaurantId
  Future<List<String>> uploadImages(String restaurantId, List<File> images) async {
    List<String> downloadUrls = [];
    for (var image in images) {
      if (kDebugMode) {
        print('Uploading image: ${image.path}');
      }
      final imageUrl = await uploadImageToFirebaseStorage(restaurantId, image);
      if (imageUrl != null) {
        downloadUrls.add(imageUrl);
      } else {
        if (kDebugMode) {
          print('Failed to upload image: ${image.path}');
        }
      }
    }
    return downloadUrls;
  }

  // Save restaurant info to Firebase Realtime Database, including uploaded image URLs
  Future<bool> saveRestaurantInfo(Restaurant restaurant) async {
    try {
      if (restaurant.selectedImage.isEmpty) {
        if (kDebugMode) {
          print('No images selected. Cannot save restaurant info.');
        }
        return false;  // Return early if no images are selected
      }

      final imageUrls = await uploadImages(
          restaurant.restaurantId, restaurant.selectedImage.map((path) => File(path)).toList());
      if (imageUrls.isEmpty) {
        if (kDebugMode) {
          print('No images uploaded. Cannot save restaurant info.');
        }
        return false;  // Return early if image upload fails
      }
      restaurant.selectedImage = imageUrls;

      final ref = _database.ref().child('restaurants').push();
      await ref.set(restaurant.toMap());

      if (kDebugMode) {
        print('Restaurant info saved successfully.');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving restaurant info: $e');
      }
      return false;
    }
  }

}