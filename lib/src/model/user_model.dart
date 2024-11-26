import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_order/src/model/reservation_model.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String profilePicture;
  final GeoPoint location;
  final String role;
  final Timestamp createdAt;

  // Subcollection
  final List<ReservationModel> reservations;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.profilePicture,
    required this.role,
    this.location = const GeoPoint(0, 0),
    required this.createdAt,
    this.reservations = const [],
  });

  factory UserModel.fromFirebase(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return UserModel(
      userId: snapshot.id,
      name: data?['name'] ?? '',
      email: data?['email'] ?? '',
      phone: data?['phone'] ?? '',
      profilePicture: data?['profilePicture'] ?? '',
      role: data?['role'] ?? '',
      createdAt: data?['created_at'] ?? Timestamp.now(),
      location: data?['location'] ?? GeoPoint(0, 0),
      reservations: data?['reservations'] is Iterable
          ? List<ReservationModel>.from(data?['reservations'])
          : [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profilePicture': profilePicture,
      'location': location,
      'role': role,
      'created_at': createdAt,
      'reservations': reservations.map((e) => e.toFirestore()).toList(),
    };
  }
}
