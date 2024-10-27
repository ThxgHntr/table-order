import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_order/src/auth/pages/login_page_view.dart';
import 'package:table_order/src/auth/pages/sign_up_page_view.dart';
import 'package:table_order/src/utils/toast_utils.dart';

import 'settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<ThemeMode>(
              value: controller.themeMode,
              onChanged: controller.updateThemeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark Theme'),
                )
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  final user = snapshot.data;
                  if (user != null) {
                    // Nếu người dùng đã đăng nhập, hiển thị nút Logout
                    return ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        showToast('Logout success');
                      },
                      child: const Text('Logout'),
                    );
                  } else {
                    // Nếu người dùng chưa đăng nhập, hiển thị nút Sign up và Login
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(LoginPageView.routeName);
                          },
                          child: const Text('Login'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(SignUpPageView.routeName);
                          },
                          child: const Text('Sign Up'),
                        ),
                      ],
                    );
                  }
                } else {
                  // Nếu đang chờ kết nối hoặc chưa lấy được trạng thái
                  return const CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
