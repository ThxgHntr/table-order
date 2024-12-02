// create a table button widget that fits the table model

import 'package:flutter/material.dart';
import 'package:table_order/src/model/table_model.dart';
import 'package:table_order/src/utils/custom_colors.dart';

class TableButton extends StatelessWidget {
  final TableModel table;
  final VoidCallback onTap;

  const TableButton({super.key, required this.table, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(table.state == 0
              ? customBlue
              : (table.state == 1 ? customYellow : customRed)),
        ),
        child: Text(
          table.tableNumber,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  } // build
}
