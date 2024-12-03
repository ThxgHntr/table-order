import 'package:flutter/material.dart';
import 'package:table_order/src/model/floor_model.dart';
import 'package:table_order/src/model/restaurant_model.dart';
import 'package:table_order/src/services/firebase_floor_services.dart';

class ChooseTableWidget extends StatefulWidget {
  const ChooseTableWidget({
    super.key,
    required this.restaurant,
    required this.dateController,
    required this.startTimeController,
    required this.endTimeController,
    required this.floorController,
  });

  final RestaurantModel restaurant;
  final TextEditingController dateController;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final TextEditingController floorController;

  @override
  State<ChooseTableWidget> createState() => ChooseTableWidgetState();
}

class ChooseTableWidgetState extends State<ChooseTableWidget> {
  String? selectedFloor;
  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;

  Future<List<FloorModel>> loadFloors(String restaurantId) async {
    final FirebaseFloorServices floorServices = FirebaseFloorServices();
    return await floorServices.loadFloors(restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.dateController,
                    readOnly: true,
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                          widget.dateController.text = pickedDate.toString();
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Ngày',
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: FutureBuilder<List<FloorModel>>(
                    future: loadFloors(widget.restaurant.restaurantId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No floors available');
                      } else {
                        return DropdownButtonFormField<String>(
                          value: selectedFloor,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedFloor = newValue;
                              widget.floorController.text = newValue!;
                            });
                          },
                          items: snapshot.data!.map<DropdownMenuItem<String>>(
                              (FloorModel floor) {
                            return DropdownMenuItem<String>(
                              value: floor.id,
                              child: Text(floor.name),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Tầng',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 16.0),
                            prefixIcon: const Icon(Icons.layers),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.startTimeController,
                    readOnly: true,
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedStartTime = pickedTime;
                          widget.startTimeController.text =
                              pickedTime.format(context);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Giờ bắt đầu',
                      prefixIcon: const Icon(Icons.access_time),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: TextField(
                    controller: widget.endTimeController,
                    readOnly: true,
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedEndTime = pickedTime;
                          widget.endTimeController.text =
                              pickedTime.format(context);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Giờ kết thúc',
                      prefixIcon: const Icon(Icons.access_time),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
