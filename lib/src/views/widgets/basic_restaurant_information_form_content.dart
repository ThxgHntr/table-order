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
      padding: const EdgeInsets.all(16.0),
      constraints: const BoxConstraints(maxWidth: 600),
      child: Form(
        key: BasicRestaurantInformationFormContent.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                labelStyle: TextStyle(color: Colors.grey),
                floatingLabelStyle: TextStyle(color: Colors.blue),
                hintText: 'Nhập tên nhà hàng',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
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
                        const SizedBox(
                          width: 16,
                          height: 16,
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
