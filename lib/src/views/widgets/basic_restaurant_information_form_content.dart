import 'package:flutter/material.dart';

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
  String? selectedCity;
  String? selectedDistrict;
  String? selectedWard;

  @override
  void initState() {
    super.initState();
    selectedCity = null;
    selectedDistrict = null;
    selectedWard = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
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
            ),
          ],
        ),
      ),
    );
  }
}
