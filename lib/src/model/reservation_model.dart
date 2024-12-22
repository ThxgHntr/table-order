import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String? id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final String floorName;
  final String tableName;
  final int seats;
  final Timestamp reserveDate;
  final Timestamp startTime;
  final Timestamp endTime;
  final bool status;
  final String notes;
  final Timestamp createdAt;
  final String ref;

  ReservationModel({
    this.id = '',
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.floorName,
    required this.tableName,
    required this.seats,
    required this.reserveDate,
    required this.startTime,
    required this.endTime,
    this.status = false,
    this.notes = '',
    required this.createdAt,
    this.ref = '',
  });

  factory ReservationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return ReservationModel(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      floorName: data['floorName'] ?? '',
      tableName: data['tableName'] ?? '',
      seats: data['seats'] ?? 0,
      reserveDate: data['reserveDate'] ?? Timestamp.now(),
      startTime: data['startTime'] ?? Timestamp.now(),
      endTime: data['endTime'] ?? Timestamp.now(),
      status: data['status'] ?? false,
      notes: data['notes'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
      ref: data['ref'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'floorName': floorName,
      'tableName': tableName,
      'seats': seats,
      'reserveDate': reserveDate,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'notes': notes,
      'created_at': createdAt,
    };
  }
}
