import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:table_order/src/auth/widgets/form_container_widget.dart';

import '../../utils/toast_utils.dart';
import '../firebase_auth_implementation/firebase_auth_services.dart';

class LoginPageView extends StatefulWidget {
  const LoginPageView({super.key});

  static const routeName = '/login';

  @override
  State<LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<LoginPageView> {
  bool _isSigning = false;
  final FirebaseAuthServices _auth = FirebaseAuthServices();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              controller: _emailController,
              hintText: "Email",
              isPasswordField: false,
            ),
            SizedBox(
              height: 15,
            ),
            FormContainerWidget(
              controller: _passwordController,
              hintText: "Password",
              isPasswordField: true,
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: 60),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: _signIn,
                child: _isSigning ? CircularProgressIndicator(color: Colors.white,): Text(
                  "Login",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: 60),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton.icon(
                onPressed: () {
                  _signInWithGoogle();
                },
                icon: Icon(FontAwesomeIcons.google, color: Colors.white,),
                label: Text(
                  "Sign in with Google",
                  style: TextStyle(color: Colors.white, fontSize: 20),
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

  Future<void> _signIn() async {

    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    setState(() {
      _isSigning = false;
    });

    if (user != null && mounted) {
      showToast("Login successfully");
      Navigator.of(context).pushNamed("/");
    } else {
      showToast("Login failed");
    }
  }

  Future<void> _signInWithGoogle() async {
    const String googleClientId = "905630379835-spgdqeb1i090663j1jhnu4rt3obsoa2i.apps.googleusercontent.com";
    final GoogleSignIn googleSignIn = GoogleSignIn(clientId: googleClientId,);
    await googleSignIn.signOut(); // Đăng xuất trước khi đăng nhập lại
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(authCredential);
        if (mounted) {
          showToast("Đăng nhập thành công");
          Navigator.of(context).pushNamed("/");
        }
      }
    } catch (e) {
      showToast("Đăng nhập thất bại");
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
