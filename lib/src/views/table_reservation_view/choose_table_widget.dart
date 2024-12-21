import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_order/src/model/floor_model.dart';
import 'package:table_order/src/model/restaurant_model.dart';
import 'package:table_order/src/model/table_model.dart';
import 'package:table_order/src/services/firebase_choose_table_service.dart';
import 'package:table_order/src/services/firebase_floor_services.dart';
import 'package:table_order/src/utils/custom_colors.dart';
import 'package:table_order/src/utils/date_time_parser.dart';
import 'package:table_order/src/utils/toast_utils.dart';
import 'package:table_order/src/views/table_reservation_view/confirm_view/confirm_choose_table_view.dart';
import 'package:table_order/src/views/widgets/annotate_box.dart';
import 'package:table_order/src/views/widgets/primary_button.dart';
import 'package:table_order/src/views/widgets/table_button.dart';

class ChooseTableWidget extends StatefulWidget {
  const ChooseTableWidget({
    super.key,
    required this.restaurant,
    required this.dateController,
    required this.startTimeController,
    required this.endTimeController,
    required this.floorController,
    required this.additionalRequestController,
  });

  final RestaurantModel restaurant;
  final TextEditingController dateController;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final TextEditingController floorController;
  final TextEditingController additionalRequestController;

  @override
  State<ChooseTableWidget> createState() => ChooseTableWidgetState();
}

class ChooseTableWidgetState extends State<ChooseTableWidget> {
  String? selectedFloor;
  String? selectedTable;
  late Future<List<FloorModel>> floors;
  Timer? _reloadTimer;

  @override
  void initState() {
    super.initState();
    floors = loadFloors(widget.restaurant.restaurantId);
  }

  @override
  void dispose() {
    _reloadTimer?.cancel();
    _cancelSelectedTable();
    super.dispose();
  }

  void _cancelSelectedTable() {
    if (selectedTable != null && selectedFloor != null) {
      FirebaseChooseTableService().cancelChooseTable(
        widget.restaurant.restaurantId,
        selectedFloor!,
        selectedTable!,
      );
      selectedTable = null;
    }
  }

  Future<List<FloorModel>> loadFloors(String restaurantId) async {
    return FirebaseFloorServices().loadFloors(restaurantId);
  }

  void _startReloadTimer() {
    _reloadTimer?.cancel();
    _reloadTimer = Timer(Duration(minutes: 5), () {
      _cancelSelectedTable();
      _resetTableList();
    });
  }

  void _resetTableList() {
    setState(() {
      floors = loadFloors(widget.restaurant.restaurantId);
    });
  }

  void _onFloorChanged(String? newValue) {
    _cancelSelectedTable();
    setState(() {
      selectedFloor = newValue;
      widget.floorController.text = newValue!;
      _resetTableList();
    });
  }

  void _onTableTap(FloorModel floor, TableModel table) async {
    if (table.state == 2) {
      showWarningToast('Bàn này đã được đặt.');
      return;
    }

    if (selectedTable == table.id) {
      _cancelSelectedTable();
      table.state = 0;
      _reloadTimer?.cancel();
    } else {
      if (selectedTable != null) {
        final previousTable =
            floor.tables.firstWhere((t) => t.id == selectedTable);
        previousTable.state = 0;
        await FirebaseChooseTableService().cancelChooseTable(
          widget.restaurant.restaurantId,
          selectedFloor!,
          previousTable.id,
        );
      }
      selectedTable = table.id;
      table.state = 1;
      bool success = await FirebaseChooseTableService().chooseTable(
        widget.restaurant.restaurantId,
        selectedFloor!,
        table.id,
      );
      if (!success) {
        showWarningToast('Không thể chọn bàn này.');
        table.state = 0;
        selectedTable = null;
      } else {
        _startReloadTimer();
      }
    }
    setState(() {});
  }

  Widget _buildRow(Widget child1, Widget child2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: child1),
        SizedBox(width: 16.0),
        Expanded(child: child2),
      ],
    );
  }

  Widget _buildAnnotateList() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnnotateBox(color: customBlue, text: 'Trống'),
        SizedBox(width: 16.0),
        AnnotateBox(color: customYellow, text: 'Đang chọn'),
        SizedBox(width: 16.0),
        AnnotateBox(color: customRed, text: 'Đã đặt'),
        _buildHelpIcon(),
      ],
    );
  }

  Widget _buildHelpIcon() {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        icon: Icon(Icons.help_outline),
        tooltip: '- Số trên bàn là số lượng ghế.\n'
            '- Chỉ được chọn một bàn tại một thời điểm.\n'
            '- Chuyển tầng sẽ hủy bàn đã chọn.\n'
            '- Bàn đã chọn sẽ tự động hủy sau 5 phút nếu không xác nhận.\n'
            '- Bạn chỉ được đặt trước tối đa 30 ngày.',
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Chú thích'),
              content: Text(
                '- Số trên bàn là số lượng ghế.\n'
                '- Chỉ được chọn một bàn tại một thời điểm.\n'
                '- Chuyển tầng sẽ hủy bàn đã chọn.\n'
                '- Bàn đã chọn sẽ tự động hủy sau 5 phút nếu không xác nhận.\n'
                '- Bạn chỉ được đặt trước tối đa 30 ngày.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Đóng'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableButtons() {
    return FutureBuilder<List<FloorModel>>(
      future: floors,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Lỗi: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('Không có bàn trống');
        } else {
          final List<TableButton> tables = snapshot.data!
              .where((floor) => floor.id == selectedFloor)
              .expand((floor) {
            return floor.tables.map((table) {
              return TableButton(
                table: table,
                isSelected: selectedTable == table.id,
                onTap: () => _onTableTap(floor, table),
              );
            }).toList();
          }).toList();

          return Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: tables,
          );
        }
      },
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildRow(
          _buildDateField(),
          _buildFloorDropdown(),
        ),
        SizedBox(height: 16.0),
        _buildRow(
          _buildStartTimeField(),
          _buildEndTimeField(),
        ),
        SizedBox(height: 16.0),
        SizedBox(
          width: 300.0,
          child: Divider(thickness: 1.0),
        ),
        SizedBox(height: 24.0),
        _buildAnnotateList(),
        SizedBox(height: 24.0),
        _buildTableButtons(),
        SizedBox(height: 24.0),
        _buildAdditionalRequestField(),
        SizedBox(height: 24.0),
        _buildConfirmButton(),
      ],
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: widget.dateController,
      readOnly: true,
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 30)),
        );
        if (pickedDate != null) {
          setState(() {
            widget.dateController.text =
                "${pickedDate.toLocal()}".split(' ')[0];
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Ngày',
        prefixIcon: const Icon(Icons.calendar_today),
      ),
    );
  }

  Widget _buildFloorDropdown() {
    return FutureBuilder<List<FloorModel>>(
      future: floors,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('Không có tầng');
        } else {
          return DropdownButtonFormField<String>(
            value: selectedFloor,
            onChanged: _onFloorChanged,
            items: snapshot.data!
                .map<DropdownMenuItem<String>>((FloorModel floor) {
              return DropdownMenuItem<String>(
                value: floor.id,
                child: Text(floor.name),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Chọn tầng',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              prefixIcon: const Icon(Icons.layers),
            ),
          );
        }
      },
    );
  }

  Widget _buildStartTimeField() {
    return TextField(
      controller: widget.startTimeController,
      readOnly: true,
      onTap: () async {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          setState(() {
            widget.startTimeController.text = pickedTime.format(context);
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Từ',
        prefixIcon: const Icon(Icons.access_time),
      ),
    );
  }

  Widget _buildEndTimeField() {
    return TextField(
      controller: widget.endTimeController,
      readOnly: true,
      onTap: () async {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          setState(() {
            widget.endTimeController.text = pickedTime.format(context);
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Đến',
        prefixIcon: const Icon(Icons.access_time),
      ),
    );
  }

  Widget _buildAdditionalRequestField() {
    return TextField(
      controller: widget.additionalRequestController,
      decoration: InputDecoration(
        labelText: 'Yêu cầu bổ sung',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        prefixIcon: const Icon(Icons.note),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return PrimaryButton(
      onPressed: () async {
        if (widget.dateController.text.isEmpty ||
            widget.startTimeController.text.isEmpty ||
            widget.endTimeController.text.isEmpty ||
            selectedFloor == null ||
            selectedTable == null) {
          showWarningToast('Vui lòng chọn đầy đủ thông tin.');
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FutureBuilder(
              future: Future.wait([
                floors.then((floors) =>
                    floors.firstWhere((floor) => floor.id == selectedFloor)),
                floors.then((floors) => floors
                    .firstWhere((floor) => floor.id == selectedFloor)
                    .tables
                    .firstWhere((table) => table.id == selectedTable)),
              ]),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final floor = snapshot.data![0] as FloorModel;
                  final table = snapshot.data![1] as TableModel;
                  return ConfirmChooseTableView(
                    restaurant: widget.restaurant,
                    floor: floor,
                    table: table,
                    date: DateTime.parse(widget.dateController.text),
                    startTime: parseTimeOfDay(widget.startTimeController.text),
                    endTime: parseTimeOfDay(widget.endTimeController.text),
                    additionalRequest: widget.additionalRequestController.text,
                  );
                }
              },
            ),
          ),
        );
      },
      buttonText: 'Đặt bàn',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.all(12.0),
        child: _buildContent(),
      ),
    );
  }
}
