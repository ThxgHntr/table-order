import 'package:flutter/material.dart';
import 'package:table_order/src/model/restaurant_model.dart';
import 'package:table_order/src/model/floor_model.dart';
import 'package:table_order/src/model/table_model.dart';
import 'package:table_order/src/services/firebase_choose_table_service.dart';
import 'package:table_order/src/views/widgets/primary_button.dart';

class ConfirmChooseTableView extends StatelessWidget {
  final RestaurantModel restaurant;
  final FloorModel floor;
  final TableModel table;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String additionalRequest;

  const ConfirmChooseTableView({
    super.key,
    required this.restaurant,
    required this.floor,
    required this.table,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.additionalRequest,
  });

  static const routeName = '/confirm-choose-table';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận đặt bàn'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nhà hàng: ${restaurant.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Tầng: ${floor.name}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Bàn: ${table.tableNumber}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Ngày: ${date.day}/${date.month}/${date.year}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Giờ bắt đầu: ${startTime.format(context)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Giờ kết thúc: ${endTime.format(context)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Yêu cầu bổ sung: $additionalRequest',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              onPressed: () {
                // Handle confirm reservation
                FirebaseChooseTableService().confirmChooseTable(
                  restaurant.restaurantId,
                  floor.id,
                  table.id,
                  date,
                  startTime,
                  endTime,
                  additionalRequest,
                );
              },
              buttonText: 'Xác nhận đặt bàn',
            ),
          ],
        ),
      ),
    );
  }
}
