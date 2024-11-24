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
  final PriceRange priceRange;
  final Map<String, String> openTime;
  final List<String> openDates;
  final double rating;
  List<File> photosToSave;
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
    required this.priceRange,
    required this.openDates,
    required this.openTime,
    required this.rating,
    this.photosToSave = const [],
    required this.photos,
    required this.ownerId,
    required this.location,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
    required this.floors,
    required this.employees,
    required this.reviews,
  });

  factory RestaurantModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return RestaurantModel(
      restaurantId: data['restaurantId'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      description: data['description'] ?? '',
      dishesStyle: List<String>.from(data['dishesStyle'] ?? []),
      priceRange: data['priceRange'] is Iterable
          ? PriceRange.fromFirestore(data['priceRange'])
          : PriceRange(lowest: 0, highest: 0),
      openDates: List<String>.from(data['openDates'] ?? []),
      openTime: Map<String, String>.from(data['openTime'] ?? {}),
      rating: data['rating']?.toDouble() ?? 0.0,
      photos: List<String>.from(data['photos'] ?? []),
      ownerId: data['ownerId'] ?? '',
      location: data['location'] ?? GeoPoint(0, 0),
      state: data['state'] ?? 0,
      createdAt: data['createdAt'] ?? 0,
      updatedAt: data['updatedAt'] ?? 0,
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
      'restaurantId': restaurantId,
      'name': name,
      'phone': phone,
      'description': description,
      'dishesStyle': dishesStyle,
      'priceRange': priceRange.toFirestore(),
      'openTime': openTime,
      'openDates': openDates,
      'rating': rating,
      'photos': photos,
      'ownerId': ownerId,
      'location': location,
      'state': state,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'floors': floors.map((e) => e.toFirestore()).toList(),
      'employees': employees.map((e) => e.toFirestore()).toList(),
      'reviews': reviews.map((e) => e.toFirestore()).toList(),
    };
  }
}

class PriceRange {
  final int lowest;
  final int highest;

  const PriceRange({required this.lowest, required this.highest});

  factory PriceRange.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return PriceRange(
      lowest: data['lowest'] as int,
      highest: data['highest'] as int,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'lowest': lowest,
      'highest': highest,
    };
  }
}