// create a table button widget that fits the table model

import 'package:flutter/material.dart';
import 'package:table_order/src/model/table_model.dart';
import 'package:table_order/src/utils/custom_colors.dart';

class TableButton extends StatelessWidget {
  final TableModel table;
  final VoidCallback onTap;

  const TableButton({super.key, required this.table, required this.onTap, required bool isSelected});

  @override
  Widget build(BuildContext context) {
    Color buttonColor;
    switch (table.state) {
      case 0:
        buttonColor = customBlue;
        break;
      case 1:
        buttonColor = customYellow;
        break;
      case 2:
        buttonColor = customRed;
        break;
      default:
        buttonColor = customBlue;
    }

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        backgroundColor: buttonColor,
      ),
      child: Text(
        table.seats.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  } // build
}
