import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Image.asset(
        'assets/logos/logo.png',
        width: isSmallScreen ? 100 : 200,
      ),
    );
  }
}
