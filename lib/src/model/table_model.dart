import 'package:cloud_firestore/cloud_firestore.dart';

class TableModel {
  final String id;
  final String tableNumber;
  final int seats;
  final int state;
  final String? reservationID;
  final String location;

  TableModel({
    this.id = '',
    required this.tableNumber,
    required this.seats,
    required this.state,
    this.reservationID,
    required this.location,
  });

  factory TableModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return TableModel(
      id: data['id'] ?? '',
      tableNumber: data['tableNumber'] ?? '',
      seats: data['seats'] ?? 0,
      state: data['state'] ?? false,
      reservationID: data['reservationID'],
      location: data['location'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'seats': seats,
      'state': state,
      'reservationID': reservationID,
      'location': location,
    };
  }
}
