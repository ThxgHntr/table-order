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
      padding: const EdgeInsets.all(20.0),
      constraints: const BoxConstraints(maxWidth: 600),
      child: Form(
        key: BasicRestaurantInformationFormContent.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
              decoration: InputDecoration(
                labelText: 'Tên nhà hàng',
                labelStyle: const TextStyle(color: Colors.grey),
                floatingLabelStyle: const TextStyle(color: Colors.blue),
                hintText: 'Nhập tên nhà hàng',
                hintStyle: const TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
                          labelStyle: const TextStyle(color: Colors.grey),
                          floatingLabelStyle: const TextStyle(color: Colors.blue),
                          hintText: 'Nhập địa chỉ',
                          hintStyle: const TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
