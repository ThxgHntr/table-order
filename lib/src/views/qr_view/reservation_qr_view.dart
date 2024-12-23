import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:table_order/src/utils/custom_colors.dart';
import 'package:table_order/src/views/restaurant_view/restaurant_item_details_view.dart';
import 'package:table_order/src/views/widgets/reservation_details.dart';

class ReservationQrView extends StatelessWidget {
  static const routeName = '/reservation-qr';

  const ReservationQrView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final bool isFromReservationList = args['isFromReservationList'] ?? false;
    final String restaurantId = args['restaurantId'];
    final String restaurantName = args['restaurantName'];
    final String floorName = args['floorName'];
    final String tableName = args['tableName'];
    final int seats = args['seats'];
    final DateTime date = args['date'];
    final TimeOfDay startTime = args['startTime'];
    final TimeOfDay endTime = args['endTime'];
    final String additionalRequest = args['additionalRequest'];
    final String qrData = args['qrData'];

    return PopScope(
      canPop: isFromReservationList,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop && isFromReservationList) {
          return;
        }
        if (context.mounted && !isFromReservationList) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        } else if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: isFromReservationList
              ? IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
              : null,
          title: Text(
            isFromReservationList ? 'QR đặt bàn' : 'QR CỦA BẠN',
            style: isFromReservationList
                ? null
                : TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: !isFromReservationList,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final double padding = constraints.maxWidth < 600 ? 20.0 : 40.0;
            final double qrSize = constraints.maxWidth < 600 ? 250.0 : 350.0;
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
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
                          restaurantName: restaurantName,
                          floorName: floorName,
                          tableName: tableName,
                          seats: seats,
                          date: date,
                          startTime: startTime,
                          endTime: endTime,
                          additionalRequest: additionalRequest,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: isFromReservationList
            ? _buildRestaurantDetailsButton(context, restaurantId)
            : _buildBottomNavigationBar(context),
      ),
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
        child: Text(
          'Trở về trang chủ',
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantDetailsButton(
      BuildContext context, String restaurantId) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // Use custom color
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Adjust border radius
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantItemDetailsView(
                restaurantId: restaurantId,
              ),
            ),
          );
        },
        child: Text(
          'Chi tiết nhà hàng',
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}