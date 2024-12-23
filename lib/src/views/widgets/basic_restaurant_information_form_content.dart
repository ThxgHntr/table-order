import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:table_order/src/utils/location_helper.dart';

import '../../utils/validation_utils.dart';

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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tên nhà hàng
            TextFormField(
              controller: widget.restaurantName,
              validator: validateRestaurantName,
              decoration: const InputDecoration(
                labelText: 'Tên nhà hàng',
                labelStyle: const TextStyle(color: Colors.grey),
                floatingLabelStyle: const TextStyle(color: Colors.blue),
                hintText: 'Nhập tên nhà hàng',
                hintStyle: const TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
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
                        validator: validateRestaurantAddress,
                        decoration: const InputDecoration(
                          labelText: 'Địa chỉ',
                          labelStyle: TextStyle(color: Colors.grey),
                          floatingLabelStyle: TextStyle(color: Colors.blue),
                          hintText: 'Nhập địa chỉ',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
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
                IconButton(
                  icon: const Icon(Icons.location_pin),
                  onPressed: _getCurrentAddress,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
