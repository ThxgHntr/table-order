import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_order/src/model/table_model.dart';

class FloorModel {
  final String id;
  final String name;
  final String description;
  final List<String> photos;

  // Subcollection
  final List<TableModel> tables;

  FloorModel({
    this.id = '',
    required this.name,
    required this.description,
    required this.photos,
    required this.tables,
  });

  factory FloorModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return FloorModel(
      id: snapshot.id,
      name: data?['name'] ?? '',
      description: data?['description'] ?? '',
      photos: List<String>.from(data?['photos'] ?? []),
      tables: data?['tables'] is Iterable
          ? List<TableModel>.from(data?['tables'])
          : [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'photos': photos,
      'tables': tables.map((e) => e.toFirestore()).toList(),
    };
  }
}
