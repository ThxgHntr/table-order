import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_order/src/model/employee_model.dart';
import 'package:table_order/src/model/floor_model.dart';
import 'package:table_order/src/model/review_model.dart';

class RestaurantModel {
  final String restaurantId;
  final String name;
  final String phone;
  final String description;
  final List<String> dishesStyle;
  final int lowestPrice;
  final int highestPrice;
  final List<String> openDates;
  final String? openTime;
  final String? closeTime;
  final double rating;
  List<File> photosToUpload;
  List<String> photos;
  final String ownerId;
  final GeoPoint location;
  final int state;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  // Subcollections
  final List<FloorModel> floors;
  final List<ReviewModel> reviews;
  final List<EmployeeModel> employees;

  RestaurantModel({
    required this.restaurantId,
    required this.name,
    required this.phone,
    required this.description,
    required this.dishesStyle,
    required this.lowestPrice,
    required this.highestPrice,
    required this.openDates,
    required this.openTime,
    required this.closeTime,
    required this.rating,
    this.photosToUpload = const [],
    this.photos = const [],
    required this.ownerId,
    required this.location,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
    this.floors = const [],
    this.employees = const [],
    this.reviews = const [],
  });

  factory RestaurantModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return RestaurantModel(
      restaurantId: snapshot.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      description: data['description'] ?? '',
      dishesStyle: List<String>.from(data['dishesStyle'] ?? []),
      lowestPrice: data['lowestPrice'] ?? 0,
      highestPrice: data['highestPrice'] ?? 0,
      openDates: List<String>.from(data['openDates'] ?? []),
      openTime: data['openTime'] ?? '',
      closeTime: data['closeTime'] ?? '',
      rating: data['rating']?.toDouble() ?? 0.0,
      photos: List<String>.from(data['photos'] ?? []),
      ownerId: data['ownerId'] ?? '',
      location: data['location'] ?? GeoPoint(0, 0),
      state: data['state'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      floors: data['floors'] is Iterable
          ? List<FloorModel>.from(data['floors'])
          : [],
      employees: data['employees'] is Iterable
          ? List<EmployeeModel>.from(data['employees'])
          : [],
      reviews: data['reviews'] is Iterable
          ? List<ReviewModel>.from(data['reviews'])
          : [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'description': description,
      'dishesStyle': dishesStyle,
      'lowestPrice': lowestPrice,
      'highestPrice': highestPrice,
      'openTime': openTime,
      'closeTime': closeTime,
      'openDates': openDates,
      'rating': rating,
      'photos': photos,
      'ownerId': ownerId,
      'location': location,
      'state': state,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
