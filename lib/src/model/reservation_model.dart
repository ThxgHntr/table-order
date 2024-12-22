import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String? id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final String floorName;
  final String tableName;
  final int seats;
  final Timestamp reservationDate;
  final Timestamp startTime;
  final Timestamp endTime;
  final String status;
  final String notes;
  final Timestamp createdAt;

  ReservationModel({
    this.id = '',
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.floorName,
    required this.tableName,
    required this.seats,
    required this.reservationDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes = '',
    required this.createdAt,
  });

  factory ReservationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return ReservationModel(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      floorName: data['floor'] ?? '',
      tableName: data['table'] ?? '',
      seats: data['seats'] ?? 0,
      reservationDate: data['reservationDate'] ?? Timestamp.now(),
      startTime: data['startTime'] ?? Timestamp.now(),
      endTime: data['endTime'] ?? Timestamp.now(),
      status: data['status'] ?? 'Pending',
      notes: data['notes'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
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
      'reservationDate': reservationDate,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'notes': notes,
      'created_at': createdAt,
    };
  }
}
