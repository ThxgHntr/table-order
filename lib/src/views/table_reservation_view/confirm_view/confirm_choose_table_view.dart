import 'package:flutter/material.dart';
import 'package:table_order/src/model/restaurant_model.dart';
import 'package:table_order/src/model/floor_model.dart';
import 'package:table_order/src/model/table_model.dart';
import 'package:table_order/src/services/firebase_choose_table_service.dart';
import 'package:table_order/src/utils/toast_utils.dart';
import 'package:table_order/src/views/qr_view/reservation_qr_view.dart';
import 'package:table_order/src/views/widgets/primary_button.dart';
import 'package:table_order/src/views/widgets/reservation_details.dart';

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
          children: [
            ReservationDetails(
              restaurantName: restaurant.name,
              floor: floor.name,
              table: table.tableNumber,
              seats: table.seats,
              date: date,
              startTime: startTime,
              endTime: endTime,
              additionalRequest: additionalRequest,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              onPressed: () async {
                final reservationId =
                    await FirebaseChooseTableService().confirmChooseTable(
                  restaurant.restaurantId,
                  restaurant.name,
                  floor.id,
                  table.id,
                  date,
                  startTime,
                  endTime,
                  additionalRequest,
                );
                if (reservationId != null) {
                  if (context.mounted) {
                    Navigator.of(context).pushNamed(
                      ReservationQrView.routeName,
                      arguments: {
                        'restaurant': restaurant,
                        'floor': floor,
                        'table': table,
                        'date': date,
                        'startTime': startTime,
                        'endTime': endTime,
                        'additionalRequest': additionalRequest,
                        'reservationId': reservationId,
                      },
                    );
                  }
                } else {
                  showWarningToast('Không thể đặt bàn.');
                }
              },
              buttonText: 'Xác nhận đặt bàn',
            ),
          ],
        ),
      ),
    );
  }
}
