import 'package:flutter/material.dart';

import '../../utils/validation_utils.dart';

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
              validator: validatePhone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                labelStyle: TextStyle(color: Colors.grey),
                floatingLabelStyle: TextStyle(color: Colors.blue),
                hintText: 'Nhập số điện thoại',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            _gap(),
            // Email
            TextFormField(
              controller: widget.restaurantEmail,
              validator: validateEmail,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.grey),
                floatingLabelStyle: TextStyle(color: Colors.blue),
                hintText: 'Nhập email',
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

  Widget _gap() {
    return const SizedBox(height: 20);
  }
}