import 'package:flutter/material.dart';
import 'package:table_order/src/model/floor_model.dart';
import 'package:table_order/src/services/firebase_floor_services.dart';

class TableManagementView extends StatefulWidget {
  final String restaurantId;

  const TableManagementView({super.key, required this.restaurantId});

  @override
  State<StatefulWidget> createState() => _TableManagementViewState();
}

class _TableManagementViewState extends State<TableManagementView> {
  final FirebaseFloorServices _floorServices = FirebaseFloorServices();
  final List<FloorModel> floors = [];

  @override
  void initState() {
    super.initState();
    _loadFloorsFromDatabase();
  }

  void _loadFloorsFromDatabase() async {
    try {
      final loadedFloors = await _floorServices.loadFloors(widget.restaurantId);
      setState(() {
        floors.clear();
        floors.addAll(loadedFloors);
      });
    } catch (e) {
      debugPrint("Lỗi tải dữ liệu tầng: $e");
    }
  }

  void _addFloor(String floorName, List<Map<String, dynamic>> tables) async {
    try {
      await _floorServices.addFloor(widget.restaurantId, floorName, tables);
      _loadFloorsFromDatabase();
    } catch (e) {
      debugPrint("Lỗi thêm tầng: $e");
    }
  }

  void _addTable(int floorIndex, String tableNumber, int chairCount) async {
    try {
      await _floorServices.addTable(
        widget.restaurantId,
        floors[floorIndex].id,
        tableNumber,
        chairCount,
      );
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
      await _floorServices.deleteFloor(
          widget.restaurantId, floors[floorIndex].id);
      _loadFloorsFromDatabase();
    } catch (e) {
      debugPrint("Lỗi xóa tầng: $e");
    }
  }

  Future<void> _deleteTable(int floorIndex, int tableIndex) async {
    try {
      await _floorServices.deleteTable(
        widget.restaurantId,
        floors[floorIndex].id,
        floors[floorIndex].tables[tableIndex].id,
      );
      _loadFloorsFromDatabase();
    } catch (e) {
      debugPrint("Lỗi xóa bàn: $e");
    }
  }

  Future<void> _updateTableStatus(
      int floorIndex, int tableIndex, int newStatus) async {
    try {
      await _floorServices.updateTableStatus(
        widget.restaurantId,
        floors[floorIndex].id,
        floors[floorIndex].tables[tableIndex].id,
        newStatus,
      );
      _loadFloorsFromDatabase();
    } catch (e) {
      debugPrint("Lỗi cập nhật trạng thái bàn: $e");
    }
  }

  void _showAddFloorDialog() {
    final floorNameController = TextEditingController();
    final chairCountController = TextEditingController();
    final List<Map<String, dynamic>> tables = [];
    int tableCounter = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Thêm tầng mới'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: floorNameController,
                        decoration: InputDecoration(labelText: 'Tên tầng'),
                      ),
                      TextField(
                        controller: chairCountController,
                        decoration: InputDecoration(labelText: 'Số lượng ghế'),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          final chairCount =
                              int.tryParse(chairCountController.text) ?? 0;
                          setState(() {
                            tables.add({
                              'tableNumber': '$tableCounter',
                              'seats': chairCount
                            });
                            tableCounter++;
                            chairCountController.clear();
                          });
                        },
                        child: Text('Thêm bàn'),
                      ),
                      SizedBox(
                        height: 100,
                        child: Scrollbar(
                          child: ListView(
                            shrinkWrap: true,
                            children: tables
                                .map((table) => Center(
                                      child: Text(
                                          '${table['tableNumber']}: ${table['seats']} ghế'),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    _addFloor(floorNameController.text, tables);
                    Navigator.pop(context);
                  },
                  child: Text('Thêm'),
                ),
              ],
            );
          },
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
                decoration: InputDecoration(labelText: 'Số lượng ghế'),
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
              onPressed: () {
                _addTable(
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
                    title: Text('Mã bàn: ${table.tableNumber}'),
                    subtitle: Text(
                        'Số lượng ghế: ${table.seats} - Trạng thái: ${_getStatusLabel(table.state)}'),
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
                            PopupMenuItem(value: 1, child: Text('Đang chọn')),
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
}
