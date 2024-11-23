import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TableManagementView extends StatefulWidget {
  final String restaurantId;

  const TableManagementView({super.key, required this.restaurantId});

  @override
  State<StatefulWidget> createState() => _TableManagementViewState();
}

class _TableManagementViewState extends State<TableManagementView> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final List<Map<String, dynamic>> floors = []; // Danh sách tầng

  @override
  void initState() {
    super.initState();
    _loadFloorsFromDatabase();
  }

  void _loadFloorsFromDatabase() async {
    try {
      final floorsSnapshot =
      await _dbRef.child('restaurants/${widget.restaurantId}/floors').get();
      if (floorsSnapshot.exists) {
        final data = floorsSnapshot.value as Map<dynamic, dynamic>;
        setState(() {
          floors.clear();
          data.forEach((key, value) {
            floors.add({
              'id': key,
              'name': value['name'],
              'tables': (value['tables'] as Map<dynamic, dynamic>?)
                  ?.entries
                  .map((entry) => {
                'id': entry.key,
                'number': entry.value['number'],
                'chairs': entry.value['chairs']
              })
                  .toList() ??
                  [],
            });
          });
        });
      } else {
        setState(() {
          floors.clear();
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải dữ liệu tầng: $e");
    }
  }

  Future<void> _addFloor(String floorName) async {
    try {
      final newFloorRef =
      _dbRef.child('restaurants/${widget.restaurantId}/floors').push();
      await newFloorRef.set({
        'name': floorName,
        'tables': {},
      });
      _loadFloorsFromDatabase();
    } catch (e) {
      debugPrint("Lỗi thêm tầng: $e");
    }
  }

  Future<void> _addTable(
      int floorIndex, String tableNumber, int chairCount) async {
    try {
      final floorId = floors[floorIndex]['id'];
      final newTableRef = _dbRef
          .child('restaurants/${widget.restaurantId}/floors/$floorId/tables')
          .push();
      await newTableRef.set({
        'number': tableNumber,
        'chairs': chairCount,
      });
      _loadFloorsFromDatabase();
    } catch (e) {
      debugPrint("Lỗi thêm bàn: $e");
    }
  }

  Future<void> _deleteFloor(int floorIndex) async {
    try {
      final floorId = floors[floorIndex]['id'];
      await _dbRef.child('restaurants/${widget.restaurantId}/floors/$floorId').remove();
      _loadFloorsFromDatabase();
    } catch (e) {
      debugPrint("Lỗi xóa tầng: $e");
    }
  }

  Future<void> _deleteTable(int floorIndex, int tableIndex) async {
    try {
      final floorId = floors[floorIndex]['id'];
      final tableId = floors[floorIndex]['tables'][tableIndex]['id'];
      await _dbRef
          .child('restaurants/${widget.restaurantId}/floors/$floorId/tables/$tableId')
          .remove();
      _loadFloorsFromDatabase();
    } catch (e) {
      debugPrint("Lỗi xóa bàn: $e");
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
                decoration: InputDecoration(labelText: 'Số bàn'),
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

  void _confirmDeleteFloor(int floorIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xóa tầng'),
          content: Text(
              'Bạn có chắc chắn muốn xóa tầng "${floors[floorIndex]['name']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteFloor(floorIndex);
                Navigator.pop(context);
              },
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteTable(int floorIndex, int tableIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xóa bàn'),
          content: Text(
              'Bạn có chắc chắn muốn xóa bàn số "${floors[floorIndex]['tables'][tableIndex]['number']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteTable(floorIndex, tableIndex);
                Navigator.pop(context);
              },
              child: Text('Xóa'),
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
        title: Text('Quản lý bàn'),
      ),
      body: ListView.builder(
        itemCount: floors.length,
        itemBuilder: (context, floorIndex) {
          final floor = floors[floorIndex];
          return ExpansionTile(
            title: Text(floor['name']),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: floor['tables'].length,
                itemBuilder: (context, tableIndex) {
                  final table = floor['tables'][tableIndex];
                  return ListTile(
                    title: Text('Bàn số: ${table['number']}'),
                    subtitle: Text('Số ghế: ${table['chairs']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () =>
                          _confirmDeleteTable(floorIndex, tableIndex),
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
                onTap: () => _confirmDeleteFloor(floorIndex),
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
