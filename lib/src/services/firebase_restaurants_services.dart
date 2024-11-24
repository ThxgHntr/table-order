import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:table_order/src/utils/file_name_handler.dart';
import '../model/restaurant_model.dart';

class FirebaseRestaurantsServices {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload image to Firebase Storage with restaurantId in the path
  Future<String?> uploadImagetoFirestoreStorage(
      String restaurantId, File image) async {
    try {
      if (!image.existsSync()) {
        if (kDebugMode) {
          print('File does not exist: ${image.path}');
        }
        return null;
      }

      final fileName = getFileNameToSave(restaurantId, image);
      final ref = _storage.ref().child(fileName);
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
  Future<List<String>> uploadImages(
      String restaurantId, List<File> images) async {
    List<String> downloadUrls = [];
    for (var image in images) {
      if (kDebugMode) {
        print('Uploading image: ${image.path}');
      }
      final imageUrl = await uploadImagetoFirestoreStorage(restaurantId, image);
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

  // Save restaurant info to Firestore, including uploaded image URLs
  Future<bool> saveRestaurantInfo(RestaurantModel restaurant) async {
    try {
      if (restaurant.photosToUpload.isEmpty) {
        if (kDebugMode) {
          print('No images selected. Cannot save restaurant info.');
        }
        return false; // Return early if no images are selected
      }

      // Save the restaurant info to Firestore
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
        return false; // Return early if image upload fails
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
