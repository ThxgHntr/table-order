import 'package:flutter/material.dart';
import 'package:table_order/src/auth/widgets/form_container_widget.dart';

class LoginPageView extends StatelessWidget {
  const LoginPageView({super.key});

  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Login",style: TextStyle(fontSize: 27,fontWeight: FontWeight.bold),),
            SizedBox(
              height: 30,
            ),
            FormContainerWidget(
              hintText: "Email",
              isPasswordField: false,
            ),
            SizedBox(
              height: 15,
            ),
            FormContainerWidget(
              hintText: "Password",
              isPasswordField: true,
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/signup');
              },
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: 60),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/signup');
                  },
                  child: Text("Sign up"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
