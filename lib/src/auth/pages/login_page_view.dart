import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPageView extends StatelessWidget {
  const LoginPageView({super.key});

  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Column(
        children: [
          Text("Login",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),)
        ],
      ),
    );
  }
}
