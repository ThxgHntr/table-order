import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String reservationId;
  final String restaurantID;
  final String floorID;
  final String tableID;
  final Timestamp reservationDate;
  final Timestamp reservationTime;
  final String status;
  final String notes;
  final Timestamp createdAt;

  ReservationModel({
    required this.reservationId,
    required this.restaurantID,
    required this.floorID,
    required this.tableID,
    required this.reservationDate,
    required this.reservationTime,
    required this.status,
    required this.notes,
    required this.createdAt,
  });

  factory ReservationModel.fromFirestore(DocumentSnapshot data) {
    return ReservationModel(
      reservationId: data['reservationId'] ?? '',
      restaurantID: data['restaurantID'] ?? '',
      floorID: data['floorID'] ?? '',
      tableID: data['tableID'] ?? '',
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
      'restaurantID': restaurantID,
      'floorID': floorID,
      'tableID': tableID,
      'reservationDate': reservationDate,
      'reservationTime': reservationTime,
      'status': status,
      'notes': notes,
      'created_at': createdAt,
    };
  }
}
