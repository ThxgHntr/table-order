import 'package:flutter/material.dart';

class AnnotateBox extends StatelessWidget {
  final Color color;
  final String text;

  const AnnotateBox({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius:
                BorderRadius.circular(4), // Adjust the radius as needed
          ),
        ),
        SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
