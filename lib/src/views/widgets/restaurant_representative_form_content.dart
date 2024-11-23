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
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: RestaurantRepresentativeFormContent.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _gap(),
            TextFormField(
              controller: widget.restaurantPhone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Làm ơn nhập số điện thoại';
                }
                return null;
              },
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
            TextFormField(
              controller: widget.restaurantEmail,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Làm ơn nhập email';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.grey),
                floatingLabelStyle: TextStyle(color: Colors.blue),
                hintText: 'Nhập email',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gap() {
    return const SizedBox(height: 10);
  }
}
