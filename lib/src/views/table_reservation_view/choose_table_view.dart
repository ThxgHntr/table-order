import 'package:flutter/material.dart';
import 'package:table_order/src/model/restaurant_model.dart';

class ChooseTableView extends StatefulWidget {
  final RestaurantModel restaurant;

  const ChooseTableView({super.key, required this.restaurant});

  static const routeName = '/choose-table';

  @override
  State<ChooseTableView> createState() => ChooseTableViewState();
}

class ChooseTableViewState extends State<ChooseTableView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt bàn'),
      ),
    );
  }
}
