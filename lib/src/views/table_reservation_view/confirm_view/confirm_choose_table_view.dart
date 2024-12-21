import 'package:flutter/material.dart';
import 'package:table_order/src/model/restaurant_model.dart';
import 'package:table_order/src/model/floor_model.dart';
import 'package:table_order/src/model/table_model.dart';
import 'package:table_order/src/services/firebase_choose_table_service.dart';
import 'package:table_order/src/utils/toast_utils.dart';
import 'package:table_order/src/views/qr_view/reservation_qr_view.dart';
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
          children: [
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          restaurant.name,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.layers),
                          const SizedBox(width: 5),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Tầng: ',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: floor.name,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.table_chart),
                          const SizedBox(width: 5),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Mã bàn: ',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: table.tableNumber,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.chair),
                          const SizedBox(width: 5),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Số ghế: ',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: table.seats.toString(),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 5),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Ngày: ',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                      '${date.day}/${date.month}/${date.year}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 5),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Từ: ',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: startTime.format(context),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 5),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Đến: ',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: endTime.format(context),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.note),
                          const SizedBox(width: 5),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Yêu cầu bổ sung: ',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: additionalRequest,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              onPressed: () async {
                final result =
                    await FirebaseChooseTableService().confirmChooseTable(
                  restaurant.restaurantId,
                  floor.id,
                  table.id,
                  date,
                  startTime,
                  endTime,
                  additionalRequest,
                );
                if (result != null) {
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
                        'reservationId': result,
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
