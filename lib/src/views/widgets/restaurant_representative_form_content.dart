import 'package:flutter/material.dart';

class RestaurantRepresentativeFormContent extends StatefulWidget {
  const RestaurantRepresentativeFormContent(
      {super.key,
        required this.restaurantPhone,
        required this.restaurantEmail});

  final TextEditingController restaurantPhone;
  final TextEditingController restaurantEmail;

  static final formKey = GlobalKey<FormState>();

  @override
  State<RestaurantRepresentativeFormContent> createState() =>
      RestaurantRepresentativeFormContentState();
}

class RestaurantRepresentativeFormContentState
    extends State<RestaurantRepresentativeFormContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      constraints: const BoxConstraints(maxWidth: 400),
      child: Form(
        key: RestaurantRepresentativeFormContent.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _gap(),
            // Số điện thoại
            TextFormField(
              controller: widget.restaurantPhone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Làm ơn nhập số điện thoại';
                }
                final numericRegex = RegExp(r'^[0-9]+$');
                if (!numericRegex.hasMatch(value)) {
                  return 'Số điện thoại chỉ được chứa số';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Số điện thoại',
                labelStyle: const TextStyle(color: Colors.grey),
                floatingLabelStyle: const TextStyle(color: Colors.blue),
                hintText: 'Nhập số điện thoại',
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
            _gap(),
            // Email
            TextFormField(
              controller: widget.restaurantEmail,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Làm ơn nhập email';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.grey),
                floatingLabelStyle: const TextStyle(color: Colors.blue),
                hintText: 'Nhập email',
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
          ],
        ),
      ),
    );
  }

  Widget _gap() {
    return const SizedBox(height: 20);
  }
}
