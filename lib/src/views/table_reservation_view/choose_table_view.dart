import 'package:flutter/material.dart';
import 'package:table_order/src/model/restaurant_model.dart';
import 'package:table_order/src/views/table_reservation_view/choose_table_widget.dart';

class ChooseTableView extends StatefulWidget {
  final RestaurantModel restaurant;

  const ChooseTableView({super.key, required this.restaurant});

  static const routeName = '/choose-table';

  @override
  State<ChooseTableView> createState() => ChooseTableViewState();
}

class ChooseTableViewState extends State<ChooseTableView> {
  final dateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final floorController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt bàn'),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            ChooseTableWidget(
                restaurant: widget.restaurant,
                dateController: dateController,
                startTimeController: startTimeController,
                endTimeController: endTimeController,
                floorController: floorController),
          ],
        ),
      ),
    );
  }
}
