import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/firebase_auth_services.dart';
import '../../utils/toast_utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginFormContent extends StatefulWidget {
  const LoginFormContent({super.key});

  @override
  State<LoginFormContent> createState() => LoginFormContentState();
}

class LoginFormContentState extends State<LoginFormContent> {
  bool _isPasswordVisible = false;
  bool _isSigning = false;
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuthServices _auth = FirebaseAuthServices();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }

                bool emailValid = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value);
                if (!emailValid) {
                  return 'Email không hợp lệ';
                }

                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Nhập email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            _gap(),
            TextFormField(
              controller: _passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }

                if (value.length < 6) {
                  return 'Mật khẩu phải chứa ít nhất 6 ký tự';
                }
                return null;
              },
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  hintText: 'Nhập mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )),
            ),
            _gap(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: _signIn,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: _isSigning ? CircularProgressIndicator(color: Colors.white,): Text(
                    'Đăng nhập',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            _gap(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: () {
                  _signInWithGoogle();
                },
                icon: Icon(FontAwesomeIcons.google),
                label: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Đăng nhập với Google',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            _gap(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Không có tài khoản? "),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/signup');
                  },
                  child: Text("Đăng ký ngay"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 13);

  Future<void> _signIn() async {
    if (_loginFormKey.currentState?.validate() ?? false) {
      setState(() {
        _isSigning = true;
      });

      String email = _emailController.text;
      String password = _passwordController.text;

      try {
        User? user = await _auth.signInWithEmailAndPassword(email, password);
        if (user != null && mounted) {
          // Gọi hàm checkRole để kiểm tra vai trò của người dùng
          String? role = await _auth.checkRole(user);

          // Kiểm tra vai trò và điều hướng tương ứng
          if (role == "admin" && mounted) {
            showToast("Đăng nhập thành công với vai trò admin");
            Navigator.of(context).pushNamed("/admin");
          } else if (mounted) {
            showToast("Đăng nhập thành công");
            Navigator.of(context).pushNamed("/");
          }
        } else {
          showToast("Đăng nhập thất bại");
        }
      } catch (e) {
        showToast("Login failed: $e");
      } finally {
        setState(() {
          _isSigning = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut(); // Đăng xuất trước khi đăng nhập lại
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(authCredential);
        User? user = userCredential.user; // Lấy User sau khi đăng nhập thành công

        if (mounted && user != null) {
          // Gọi hàm checkRole để kiểm tra vai trò của người dùng
          String? role = await _auth.checkRole(user);

          // Kiểm tra vai trò và điều hướng tương ứng
          if (role == "admin" && mounted) {
            showToast("Login successful as admin");
            Navigator.of(context).pushNamed("/admin");
          } else if (mounted) {
            showToast("Login successful${role != null ? " as $role" : ""}");
            Navigator.of(context).pushNamed("/");
          }
        }
      }
    } catch (e) {
      // In lỗi chi tiết ra console để debug
      showToast("Đăng nhập thất bại");
      if (kDebugMode) {
        // In ra lỗi cụ thể để debug dễ dàng
        print("Error: ${e.toString()}");

        // Kiểm tra lỗi chi tiết từ FirebaseAuth
        if (e is FirebaseAuthException) {
          // Bạn có thể in ra mã lỗi và mô tả chi tiết của FirebaseAuthException
          print("FirebaseAuthError: ${e.code} - ${e.message}");
        } else {
          // Xử lý các lỗi khác (nếu có)
          print("Non-Firebase error: $e");
        }
      }
    }
  }
}