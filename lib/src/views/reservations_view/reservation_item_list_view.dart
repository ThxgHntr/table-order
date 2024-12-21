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
    _reservationsFuture = FirebaseReservationServices().getReservationListForUser();
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
            return Center(child: Text('No reservations found.'));
          } else {
            final reservations = snapshot.data!;
            return ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                return ListTile(
                  title: Text('Reservation ID: ${reservation.id}'),
                  subtitle: Text('Status: ${reservation.status}'),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      ReservationQrView.routeName,
                      arguments: {
                        'reservationId': reservation.id,
                        // 'restaurant': reservation.restaurant,
                        // 'floor': reservation.floor,
                        // 'table': reservation.table,
                        'date': reservation.reservationDate.toDate(),
                        'startTime': TimeOfDay.fromDateTime(reservation.startTime.toDate()),
                        'endTime': TimeOfDay.fromDateTime(reservation.endTime.toDate()),
                        'additionalRequest': reservation.notes,
                      },
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
