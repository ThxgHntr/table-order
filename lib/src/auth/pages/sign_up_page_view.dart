import 'package:flutter/material.dart';

import '../widgets/logo.dart';
import '../widgets/signup_form_content.dart';


class SignUpPageView extends StatefulWidget {
  const SignUpPageView({super.key});

  static const routeName = '/signup';

  @override
  State<SignUpPageView> createState() => _SignUpPageViewState();
}

class _SignUpPageViewState extends State<SignUpPageView> {
  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      body: Center(
          child: isSmallScreen
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Logo(),
              SignupFormContent(),
            ],
          )
              : Container(
            padding: const EdgeInsets.all(32.0),
            constraints: const BoxConstraints(maxWidth: 800),
            child: Row(
              children: const [
                Expanded(child: Logo()),
                Expanded(
                  child: Center(child: SignupFormContent()),
                ),
              ],
            ),
          )),
    );
  }
}
