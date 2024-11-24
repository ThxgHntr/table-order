import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/toast_utils.dart';

class ProfilePageView extends StatefulWidget {
  const ProfilePageView({super.key});

  static const routeName = '/profile';

  @override
  State<ProfilePageView> createState() => _ProfilePageViewState();
}

class _ProfilePageViewState extends State<ProfilePageView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView(
            children: [
              _SingleSection(
                children: [
                  if (user != null) ...[
                    Container(
                      color: Colors.orange,
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(user.photoURL ??
                                'https://via.placeholder.com/150'),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            user.displayName ?? 'No Name',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      color: Colors.orange,
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                AssetImage('assets/images/default_avatar.png'),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Guest',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              _SingleSection(
                title: "Tổng quan",
                children: [
                  _CustomListTile(
                    title: "Danh sách nhà hàng",
                    icon: Icons.store,
                    onTap: () {
                      if (user == null) {
                        showToast("Bạn cần đăng nhập để truy cập");
                      } else {
                        Navigator.pushNamed(context, '/restaurant-owner');
                      }
                    },
                  ),
                  const _CustomListTile(
                      title: "Trợ giúp", icon: Icons.help_outline_rounded),
                  const _CustomListTile(
                      title: "Về chúng tôi", icon: Icons.info_outline_rounded),
                ],
              ),
              const Divider(),
              _SingleSection(
                children: user != null
                    ? [
                        _CustomListTile(
                          title: "Đăng xuất",
                          icon: Icons.exit_to_app_rounded,
                          onTap: () async {
                            await _auth.signOut();
                            setState(() {});
                          },
                        ),
                      ]
                    : [
                        _CustomListTile(
                          title: "Đăng nhập",
                          icon: Icons.login_rounded,
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                        ),
                        _CustomListTile(
                          title: "Đăng ký",
                          icon: Icons.app_registration_rounded,
                          onTap: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                        ),
                      ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _CustomListTile({
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: onTap,
    );
  }
}

class _SingleSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _SingleSection({
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        Column(
          children: children,
        ),
      ],
    );
  }
}
