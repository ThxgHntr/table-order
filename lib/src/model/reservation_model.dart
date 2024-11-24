import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String reservationId;
  final String restaurantId;
  final String floorId;
  final String tableId;
  final Timestamp reservationDate;
  final Timestamp reservationTime;
  final String status;
  final String notes;
  final Timestamp createdAt;

  ReservationModel({
    required this.reservationId,
    required this.restaurantId,
    required this.floorId,
    required this.tableId,
    required this.reservationDate,
    required this.reservationTime,
    required this.status,
    required this.notes,
    required this.createdAt,
  });

  factory ReservationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return ReservationModel(
      reservationId: data['reservationId'] ?? '',
      restaurantId: data['restaurantID'] ?? '',
      floorId: data['floorID'] ?? '',
      tableId: data['tableID'] ?? '',
      reservationDate: data['reservationDate'] ?? Timestamp.now(),
      reservationTime: data['reservationTime'] ?? Timestamp.now(),
      status: data['status'] ?? 'Pending',
      notes: data['notes'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reservationId': reservationId,
      'restaurantId': restaurantId,
      'floorId': floorId,
      'tableId': tableId,
      'reservationDate': reservationDate,
      'reservationTime': reservationTime,
      'status': status,
      'notes': notes,
      'created_at': createdAt,
    };
  }
}
