import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:table_order/src/utils/file_name_handler.dart';
import '../model/restaurant_model.dart';
import '../utils/file_handler.dart';

class FirebaseRestaurantsServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //ham lay owner id dua tren restaurant id
  Future<String?> getOwnerId(String restaurantId) async {
    try {
      final restaurantRef = _firestore.collection('restaurants').doc(restaurantId);
      final restaurantDoc = await restaurantRef.get();
      final ownerId = restaurantDoc.get('ownerId');
      return ownerId;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting owner id: $e');
      }
      return null;
    }
  }

  Future<String?> uploadImagetoFirestoreStorage(
      String restaurantId, File image) async {
    final fileName = getFileNameToSave(restaurantId, image);
    return await uploadImageToStorage(fileName, image);
  }

  Future<List<String>> uploadImages(
      String restaurantId, List<File> images) async {
    List<String> downloadUrls = [];
    for (var image in images) {
      final imageUrl = await uploadImagetoFirestoreStorage(restaurantId, image);
      if (imageUrl != null) {
        downloadUrls.add(imageUrl);
      }
    }
    return downloadUrls;
  }

  Future<bool> saveRestaurantInfo(RestaurantModel restaurant) async {
    try {
      if (restaurant.photosToUpload.isEmpty) {
        if (kDebugMode) {
          print('No images selected. Cannot save restaurant info.');
        }
        return false;
      }

      final restaurantRef =
      _firestore.collection('restaurants').doc(restaurant.restaurantId);
      await restaurantRef.set(restaurant.toFirestore());
      restaurantRef.collection('floors').doc();
      restaurantRef.collection('employees').doc();
      restaurantRef.collection('reviews').doc();

      final imageUrls = await uploadImages(
          restaurant.restaurantId, restaurant.photosToUpload);
      restaurant.photos = imageUrls;
      await restaurantRef.update({'photos': imageUrls});

      if (imageUrls.isEmpty) {
        if (kDebugMode) {
          print('No images uploaded. Cannot save restaurant info.');
        }
        return false;
      }

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