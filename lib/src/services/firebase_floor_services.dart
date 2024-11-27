import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_order/src/model/floor_model.dart';
import 'package:table_order/src/model/table_model.dart';

class FirebaseFloorServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<FloorModel>> loadFloors(String restaurantId) async {
    final restaurantRef = _firestore.collection('restaurants');
    final floorsSnapshot = await restaurantRef.doc(restaurantId).collection('floors').get();

    List<FloorModel> floors = [];
    for (var doc in floorsSnapshot.docs) {
      final floor = FloorModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);

      // Load tables for each floor
      final tablesSnapshot = await restaurantRef.doc(restaurantId).collection('floors').doc(floor.id).collection('tables').get();

      final tables = tablesSnapshot.docs.map((tableDoc) {
        return TableModel.fromFirestore(tableDoc as DocumentSnapshot<Map<String, dynamic>>);
      }).toList();

      floors.add(FloorModel(
        id: floor.id,
        name: floor.name,
        description: floor.description,
        photos: floor.photos,
        tables: tables,
      ));
    }
    return floors;
  }

  Future<void> addFloor(String restaurantId, String floorName) async {
    final restaurantRef = _firestore.collection('restaurants');
    final newFloorRef = restaurantRef.doc(restaurantId).collection('floors').doc();

    await newFloorRef.set({
      'name': floorName,
    });
  }

  Future<void> addTable(String restaurantId, String floorId, String tableNumber, int chairCount) async {
    final restaurantRef = _firestore.collection('restaurants');
    final newTableRef = restaurantRef.doc(restaurantId).collection('floors').doc(floorId).collection('tables').doc();

    await newTableRef.set({
      'tableNumber': tableNumber,
      'seats': chairCount,
      'state': 0, // Trạng thái mặc định
    });
  }

  Future<void> deleteFloor(String restaurantId, String floorId) async {
    final restaurantRef = _firestore.collection('restaurants');
    await restaurantRef.doc(restaurantId).collection('floors').doc(floorId).delete();
  }

  Future<void> deleteTable(String restaurantId, String floorId, String tableId) async {
    final restaurantRef = _firestore.collection('restaurants');
    await restaurantRef.doc(restaurantId).collection('floors').doc(floorId).collection('tables').doc(tableId).delete();
  }

  Future<void> updateTableStatus(String restaurantId, String floorId, String tableId, int newStatus) async {
    final restaurantRef = _firestore.collection('restaurants');
    await restaurantRef.doc(restaurantId).collection('floors').doc(floorId).collection('tables').doc(tableId).update({'state': newStatus});
  }
}