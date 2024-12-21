import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReservationQrView extends StatelessWidget {
  static const routeName = '/reservation-qr';

  const ReservationQrView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'QR CỦA BẠN',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final double padding = constraints.maxWidth < 600 ? 20.0 : 40.0;
            final double qrSize = constraints.maxWidth < 600 ? 200.0 : 300.0;
            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20.0),
                  Center(
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
                  ),
                  const SizedBox(height: 10.0),
                  const Text(
                    'Bạn có thể quét mã QR này tại nhà hàng',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
