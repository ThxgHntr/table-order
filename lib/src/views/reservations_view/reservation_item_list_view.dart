import 'package:flutter/material.dart';
import 'package:table_order/src/services/firebase_reservation_services.dart';
import 'package:table_order/src/model/reservation_model.dart';
import 'package:table_order/src/views/qr_view/reservation_qr_view.dart';

class ReservationItemListView extends StatefulWidget {
  static const routeName = '/reservations';

  const ReservationItemListView({super.key});

  @override
  State<StatefulWidget> createState() => ReservationItemListViewState();
}

class ReservationItemListViewState extends State<ReservationItemListView> {
  late Future<List<ReservationModel>> _reservationsFuture;

  @override
  void initState() {
    super.initState();
    _reservationsFuture =
        FirebaseReservationServices().getReservationListForUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách mã đặt bàn',
            style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: FutureBuilder<List<ReservationModel>>(
        future: _reservationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có mã đặt bàn nào'));
          } else {
            final reservations = snapshot.data!;
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    return Column(
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: 375,
                            minWidth: 0, // Ensure minWidth is less than or equal to maxWidth

                          ), // Responsive card width
                          child: Card(
                            child: ListTile(
                              leading: Icon(Icons.table_bar),
                              title: Text(
                                'Tên nhà hàng: ${reservation.restaurantName}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(width: 5),
                                      Text(
                                        reservation.status
                                            ? 'Đã sử dụng'
                                            : 'Chưa sử dụng',
                                        style: TextStyle(
                                          color: reservation.status
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Ngày đặt: ${reservation.reserveDate.toDate().toString().substring(0, 10)}',
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  ReservationQrView.routeName,
                                  arguments: {
                                    'isFromReservationList': true,
                                    'qrData': reservation.ref,
                                    'restaurantId': reservation.restaurantId,
                                    'restaurantName':
                                    reservation.restaurantName,
                                    'floorName': reservation.floorName,
                                    'tableName': reservation.tableName,
                                    'seats': reservation.seats,
                                    'date': reservation.reserveDate.toDate(),
                                    'startTime': TimeOfDay.fromDateTime(
                                        reservation.startTime.toDate()),
                                    'endTime': TimeOfDay.fromDateTime(
                                        reservation.endTime.toDate()),
                                    'additionalRequest': reservation.notes,
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 4.0), // Reduced space between cards
                      ],
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

