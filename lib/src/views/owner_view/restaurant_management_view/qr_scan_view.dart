import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:table_order/src/services/firebase_restaurants_services.dart';

class QrScanView extends StatefulWidget {
  static const String routeName = '/owner/restaurant_management/qr';
  const QrScanView({super.key});

  @override
  State<QrScanView> createState() => _QrScanViewState();
}

class _QrScanViewState extends State<QrScanView> {
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quét mã QR'),
      ),
      body: MobileScanner(
        onDetect: (barcodeCapture) async {
          if (_isScanning) return;
          _isScanning = true;

          final String? code = barcodeCapture.barcodes.first.rawValue;
          if (code != null) {
            Future<bool> isApproved =
                FirebaseRestaurantsServices().approveReservation(code);
            if (await isApproved) {
              Fluttertoast.showToast(
                msg: 'Mã QR hợp lệ.',
                toastLength: Toast.LENGTH_SHORT,
              );
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            } else {
              Fluttertoast.showToast(
                msg: 'Mã QR không hợp lệ. Vui lòng thử lại.',
                toastLength: Toast.LENGTH_SHORT,
              );
            }
          }

          await Future.delayed(Duration(seconds: 2));
          _isScanning = false;
        },
      ),
    );
  }
}
