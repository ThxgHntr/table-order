import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_order/src/model/floor_model.dart';
import 'package:table_order/src/model/table_model.dart';

class TableManagementView extends StatefulWidget {
  final String restaurantId;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  TableManagementView({super.key, required this.restaurantId});

  @override
  State<StatefulWidget> createState() => _TableManagementViewState();
}

class _TableManagementViewState extends State<TableManagementView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<FloorModel> floors = [];
  late CollectionReference<Map<String, dynamic>> restaurantRef;

  @override
  void initState() {
    super.initState();
    restaurantRef = _firestore.collection('restaurants');
    _loadFloorsFromDatabase();
  }

  void _loadFloorsFromDatabase() async {
    try {
      final floorsSnapshot = await restaurantRef
          .doc(widget.restaurantId)
          .collection('floors')
          .get();

      setState(() {
        floors.clear();
      });

      for (var doc in floorsSnapshot.docs) {
        final floor = FloorModel.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>);

        // Load tables for each floor
        final tablesSnapshot =
        await restaurantRef.doc(widget.restaurantId).collection('floors').doc(floor.id).collection('tables').get();

        final tables = tablesSnapshot.docs.map((tableDoc) {
          return TableModel.fromFirestore(
              tableDoc as DocumentSnapshot<Map<String, dynamic>>);
        }).toList();

        setState(() {
          floors.add(FloorModel(
            id: floor.id,
            name: floor.name,
            description: floor.description,
            photos: floor.photos,
            tables: tables,
          ));
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải dữ liệu tầng: $e");
    }
  }

  Future<void> _addFloor(String floorName) async {
    try {
      final newFloorRef =
      restaurantRef.doc(widget.restaurantId).collection('floors').doc();

      await newFloorRef.set({
        'name': floorName,
      });
      _loadFloorsFromDatabase();
    } catch (e) {
      debugPrint("Lỗi thêm tầng: $e");
    }
  }

  Future<void> _addTable(int floorIndex, String tableNumber, int chairCount) async {
    try {
      final floorId = floors[floorIndex].id;
      final newTableRef = restaurantRef
          .doc(widget.restaurantId)
          .collection('floors')
          .doc(floorId)
          .collection('tables')
          .doc();

      await newTableRef.set({
        'tableNumber': tableNumber,
        'seats': chairCount,
        'state': 0, // Trạng thái mặc định
      });
      _loadFloorsFromDatabase();
    } catch (e) {
      debugPrint("Lỗi thêm bàn: $e");
    }
  }

  Future<void> _deleteFloor(int floorIndex) async {
    if (floors[floorIndex].tables.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể xóa tầng vì còn bàn trong tầng.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final floorId = floors[floorIndex].id;
      await _firestore
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('floors')
          .doc(floorId)
          .delete();
      _loadFloorsFromDatabase();
    } catch (e) {
      debugPrint("Lỗi xóa tầng: $e");
    }
  }

  Future<void> _deleteTable(int floorIndex, int tableIndex) async {
    try {
      final floorId = floors[floorIndex].id;
      final tableId = floors[floorIndex].tables[tableIndex].id;
      await _firestore
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('floors')
          .doc(floorId)
          .collection('tables')
          .doc(tableId)
          .delete();
      _loadFloorsFromDatabase();
    } catch (e) {
      debugPrint("Lỗi xóa bàn: $e");
    }
  }

  Future<void> _updateTableStatus(
      int floorIndex, int tableIndex, int newStatus) async {
    try {
      final floorId = floors[floorIndex].id;
      final tableId = floors[floorIndex].tables[tableIndex].id;
      await _firestore
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('floors')
          .doc(floorId)
          .collection('tables')
          .doc(tableId)
          .update({'state': newStatus});
      _loadFloorsFromDatabase();
    } catch (e) {
      debugPrint("Lỗi cập nhật trạng thái bàn: $e");
    }
  }

  String _getStatusLabel(int status) {
    switch (status) {
      case 0:
        return 'Chưa có ai đặt';
      case 1:
        return 'Đã đặt';
      case 2:
        return 'Đang sử dụng';
      default:
        return 'Không xác định';
    }
  }

  void _showAddFloorDialog() {
    final floorNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm tầng mới'),
          content: TextField(
            controller: floorNameController,
            decoration: InputDecoration(labelText: 'Tên tầng'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                await _addFloor(floorNameController.text);
                Navigator.pop(context);
              },
              child: Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTableDialog(int floorIndex) {
    final tableNumberController = TextEditingController();
    final chairCountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm bàn mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tableNumberController,
                decoration: InputDecoration(labelText: 'Mã bàn'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: chairCountController,
                decoration: InputDecoration(labelText: 'Số ghế'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                await _addTable(
                  floorIndex,
                  tableNumberController.text,
                  int.tryParse(chairCountController.text) ?? 0,
                );
                Navigator.pop(context);
              },
              child: Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý tầng'),
      ),
      body: ListView.builder(
        itemCount: floors.length,
        itemBuilder: (context, floorIndex) {
          final floor = floors[floorIndex];
          return ExpansionTile(
            title: Text(floor.name),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: floor.tables.length,
                itemBuilder: (context, tableIndex) {
                  final table = floor.tables[tableIndex];
                  return ListTile(
                    title: Text('Bàn số: ${table.tableNumber}'),
                    subtitle: Text(
                        'Số ghế: ${table.seats} - Trạng thái: ${_getStatusLabel(table.state)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<int>(
                          icon: Icon(Icons.more_vert),
                          onSelected: (newStatus) => _updateTableStatus(
                              floorIndex, tableIndex, newStatus),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                                value: 0, child: Text('Chưa có ai đặt')),
                            PopupMenuItem(value: 1, child: Text('Đã đặt')),
                            PopupMenuItem(
                                value: 2, child: Text('Đang sử dụng')),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTable(floorIndex, tableIndex),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.add),
                title: Text('Thêm bàn mới'),
                onTap: () => _showAddTableDialog(floorIndex),
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Xóa tầng này'),
                onTap: () => _deleteFloor(floorIndex),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFloorDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
