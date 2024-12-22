import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:table_order/src/services/firebase_restaurants_services.dart';
import 'package:table_order/src/views/owner_view/restaurant_management_view/review_management_view.dart';
import 'package:table_order/src/views/owner_view/restaurant_management_view/table_management_view.dart';

class RestaurantOwnerManagementView extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const RestaurantOwnerManagementView(
      {super.key, required this.restaurantId, required this.restaurantName});

  static const String routeName = '/owner/restaurant_management';

  @override
  State<StatefulWidget> createState() => _RestaurantOwnerManagementViewState();
}

class _RestaurantOwnerManagementViewState
    extends State<RestaurantOwnerManagementView> {
  void _scanQRCode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRViewScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurantName),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.qr_code_scanner_sharp),
            onPressed: _scanQRCode,
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Display popup to edit restaurant information
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine how many columns to show based on screen width
            int crossAxisCount = 2;
            if (constraints.maxWidth >= 1000) {
              crossAxisCount = 4; // Show 4 columns on larger screens
            } else if (constraints.maxWidth >= 600) {
              crossAxisCount = 3; // Show 3 columns on medium screens
            }

            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1000),
              child: GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16.0, // Space between columns
                mainAxisSpacing: 16.0, // Space between rows
                children: <Widget>[
                  _buildDashboardItem(Icons.table_bar, 'Bàn đã được đặt'),
                  _buildDashboardItem(Icons.star, 'Đánh giá'),
                  _buildDashboardItem(
                      Icons.pivot_table_chart_rounded, 'Quản lý tầng'),
                  _buildDashboardItem(Icons.group, 'Quản lý nhân viên'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardItem(IconData icon, String title) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          if (title == 'Quản lý tầng') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TableManagementView(
                  restaurantId: widget.restaurantId,
                ),
              ),
            );
          } else if (title == 'Đánh giá') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewManagementView(
                  restaurantId: widget.restaurantId,
                ),
              ),
            );
          } else if (title == 'Quản lý nhân viên') {
            // Handle navigation to employee management view
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 60.0), // Adjust icon size
            const SizedBox(height: 8.0), // Space between icon and text
            Text(
              title,
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class QRViewScreen extends StatelessWidget {
  const QRViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quét mã QR'),
      ),
      body: MobileScanner(
        onDetect: (barcodeCapture) async {
          final String? code = barcodeCapture.barcodes.first.rawValue;
          if (code != null) {
            if (kDebugMode) {
              print(code);
            }
            Future<bool> isApproved =
                FirebaseRestaurantsServices().approveReservation(code);
            if (await isApproved) {
              Fluttertoast.showToast(
                msg: 'Mã QR hợp lệ.',
                toastLength: Toast.LENGTH_SHORT,
              );
              Navigator.pop(context);
            } else {
              Fluttertoast.showToast(
                msg: 'Mã QR không hợp lệ. Vui lòng thử lại.',
                toastLength: Toast.LENGTH_SHORT,
              );
            }
          }
        },
      ),
    );
  }
}
