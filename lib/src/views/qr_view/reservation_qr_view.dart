import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:table_order/src/model/floor_model.dart';
import 'package:table_order/src/model/restaurant_model.dart';
import 'package:table_order/src/model/table_model.dart';
import 'package:table_order/src/utils/custom_colors.dart';
import 'package:table_order/src/views/widgets/reservation_details.dart';

class ReservationQrView extends StatelessWidget {
  static const routeName = '/reservation-qr';

  const ReservationQrView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final RestaurantModel restaurant = args['restaurant'];
    final FloorModel floor = args['floor'];
    final TableModel table = args['table'];
    final DateTime date = args['date'];
    final TimeOfDay startTime = args['startTime'];
    final TimeOfDay endTime = args['endTime'];
    final String additionalRequest = args['additionalRequest'];
    final String qrData = args['reservationId'];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final double padding = constraints.maxWidth < 600 ? 20.0 : 40.0;
            final double qrSize = constraints.maxWidth < 600 ? 200.0 : 300.0;
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20.0),
                    _buildQrCode(qrData, qrSize),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Bạn có thể quét mã QR này tại nhà hàng',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Divider(
                      color: Colors.grey,
                      thickness: 1.0,
                    ),
                    const SizedBox(height: 10.0),
                    ReservationDetails(
                      restaurant: restaurant,
                      floor: floor,
                      table: table,
                      date: date,
                      startTime: startTime,
                      endTime: endTime,
                      additionalRequest: additionalRequest,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        'QR CỦA BẠN',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildQrCode(String qrData, double qrSize) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: qrSize,
            embeddedImage: AssetImage('assets/logos/logo.png'),
            embeddedImageStyle: QrEmbeddedImageStyle(
              size: Size(153 / 4, 115 / 4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // Use custom color
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Adjust border radius
          ),
        ),
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        },
        child: const Text(
          'Trở về trang chủ',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
