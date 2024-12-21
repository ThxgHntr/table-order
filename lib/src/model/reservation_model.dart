import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String? id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final String floor;
  final String table;
  final String seats;
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
    required this.floor,
    required this.table,
    required this.seats,
    required this.reservationDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.notes,
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
      floor: data['floor'] ?? '',
      table: data['table'] ?? '',
      seats: data['seats'] ?? '',
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
      'reservationDate': reservationDate,
      'userId': userId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'floor': floor,
      'table': table,
      'seats': seats,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'notes': notes,
      'created_at': createdAt,
    };
  }
}
