import 'package:flutter/material.dart';

import '../widgets/login_form_content.dart';
import '../widgets/logo.dart';

class LoginPageView extends StatefulWidget {
  const LoginPageView({super.key});

  static const routeName = '/login';

  @override
  State<LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<LoginPageView> {
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
                LoginFormContent(),
              ],
            )
                : Container(
              padding: const EdgeInsets.all(32.0),
              constraints: const BoxConstraints(maxWidth: 800),
              child: Row(
                children: const [
                  Expanded(child: Logo()),
                  Expanded(
                    child: Center(child: LoginFormContent()),
                  ),
                ],
              ),
            )),
    );
  }
}
