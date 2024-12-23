import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:table_order/src/utils/location_helper.dart';

class BasicRestaurantInformationFormContent extends StatefulWidget {
  const BasicRestaurantInformationFormContent({
    super.key,
    required this.restaurantName,
    required this.restaurantAddress,
  });

  final TextEditingController restaurantName;
  final TextEditingController restaurantAddress;

  static final formKey = GlobalKey<FormState>();

  @override
  State<BasicRestaurantInformationFormContent> createState() =>
      BasicRestaurantInformationFormContentState();
}

class BasicRestaurantInformationFormContentState
    extends State<BasicRestaurantInformationFormContent> {
  bool _isLoading = false;

  Future<void> _getCurrentAddress() async {
    setState(() {
      _isLoading = true;
    });
    Position? currentPosition = await getCurrentLocation();
    if (currentPosition != null) {
      String address = await getAddressFromGeopoint(
          GeoPoint(currentPosition.latitude, currentPosition.longitude));
      setState(() {
        widget.restaurantAddress.text = address;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Form(
        key: BasicRestaurantInformationFormContent.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tên nhà hàng
            TextFormField(
              controller: widget.restaurantName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Làm ơn nhập tên nhà hàng';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Tên nhà hàng',
                hintText: 'Nhập tên nhà hàng',
                prefixIcon: Icon(Icons.drive_file_rename_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Địa chỉ nhà hàng
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      TextFormField(
                        controller: widget.restaurantAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Làm ơn nhập địa chỉ';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Địa chỉ',
                          hintText: 'Nhập địa chỉ',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(),
                        ),
                        enabled: !_isLoading,
                      ),
                      if (_isLoading)
                        const Positioned(
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _getCurrentAddress,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(12), backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.location_pin, size: 30, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
