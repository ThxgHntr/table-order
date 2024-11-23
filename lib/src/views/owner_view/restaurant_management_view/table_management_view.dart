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
  final List<Map<String, dynamic>> floors = [];

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
                'chairs': entry.value['chairs'],
                'status': entry.value['status'] ?? 0,
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
        'status': 0, // Trạng thái mặc định
      });
      _loadFloorsFromDatabase();
    } catch (e) {
      debugPrint("Lỗi thêm bàn: $e");
    }
  }

  Future<void> _deleteFloor(int floorIndex) async {
    if (floors[floorIndex]['tables'].isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể xóa tầng vì còn bàn trong tầng.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final floorId = floors[floorIndex]['id'];
      await _dbRef
          .child('restaurants/${widget.restaurantId}/floors/$floorId')
          .remove();
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
          .child(
          'restaurants/${widget.restaurantId}/floors/$floorId/tables/$tableId')
          .remove();
      _loadFloorsFromDatabase();
    } catch (e) {
      debugPrint("Lỗi xóa bàn: $e");
    }
  }

  Future<void> _updateTableStatus(
      int floorIndex, int tableIndex, int newStatus) async {
    try {
      final floorId = floors[floorIndex]['id'];
      final tableId = floors[floorIndex]['tables'][tableIndex]['id'];
      await _dbRef
          .child(
          'restaurants/${widget.restaurantId}/floors/$floorId/tables/$tableId')
          .update({'status': newStatus});
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
                    subtitle: Text(
                        'Số ghế: ${table['chairs']} - Trạng thái: ${_getStatusLabel(table['status'])}'),
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
                            PopupMenuItem(value: 2, child: Text('Đang sử dụng')),
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
