import 'package:cloud_firestore/cloud_firestore.dart';

class TableModel {
  final String id;
  final String tableNumber;
  final int seats;
  late int state;
  late String userId = '';

  TableModel({
    this.id = '',
    required this.tableNumber,
    required this.seats,
    required this.state,
    this.userId = '',
  });

  factory TableModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return TableModel(
      id: snapshot.id,
      tableNumber: data['tableNumber'] ?? '',
      seats: data['seats'] ?? 0,
      state: data['state'] ?? false,
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tableNumber': tableNumber,
      'seats': seats,
      'state': state,
      'userId': userId,
    };
  }
}
