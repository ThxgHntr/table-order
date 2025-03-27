import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_order/src/services/firebase_auth_services.dart';
import 'package:table_order/src/utils/custom_colors.dart';

import '../../utils/toast_utils.dart';
import '../../model/user_model.dart';
import '../widgets/edit_user_profile.dart';

class ProfilePageView extends StatefulWidget {
  const ProfilePageView({super.key});

  static const routeName = '/profile';

  @override
  State<ProfilePageView> createState() => _ProfilePageViewState();
}

class _ProfilePageViewState extends State<ProfilePageView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _userModel;

  @override
  void initState() {
    super.initState();
    _fetchUserModel();
  }

  Future<void> _fetchUserModel() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      setState(() {
        _userModel = UserModel.fromFirebase(snapshot);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;
    final bool isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Trang cá nhân',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.left, // Align text to the left
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileHeader(currentUser),
              const SizedBox(height: 16),
              Expanded(
                child: isLargeScreen
                    ? GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildOverviewSection(currentUser),
                          _buildAccountActionsSection(currentUser),
                        ],
                      )
                    : ListView(
                        children: [
                          _buildOverviewSection(currentUser),
                          const SizedBox(height: 16),
                          _buildAccountActionsSection(currentUser),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    String profilePictureUrl = 'https://via.placeholder.com/150';
    if (user != null && user.providerData.isNotEmpty) {
      String providerId = user.providerData[0].providerId;
      if (providerId == 'google.com') {
        profilePictureUrl = user.photoURL ?? 'https://via.placeholder.com/150';
      } else if (providerId == 'password') {
        profilePictureUrl =
            _userModel?.profilePicture ?? 'https://via.placeholder.com/150';
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [customRed, primaryColor], // Gradient colors
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(profilePictureUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Khách',
                  style: const TextStyle(
                    fontSize: 18, // Increased font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  user?.email ?? 'Chưa có email',
                  style: const TextStyle(
                    fontSize: 16, // Larger font size
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      _getAuthProviderIcon(user),
                      color: Colors.white70,
                      size: 24, // Larger icon size
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getAuthProvider(user),
                      style: const TextStyle(
                        fontSize: 16, // Larger font size
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // IconButton to edit profile
          if (user != null &&
              user.providerData.isNotEmpty &&
              user.providerData[0].providerId == 'password')
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditUserProfile(),
                  ),
                );
                if (result == true) {
                  await _fetchUserModel();
                }
              },
            ),
        ],
      ),
    );
  }

  String _getAuthProvider(User? user) {
    if (user == null) return 'Chưa đăng nhập';
    // Check the provider of the user (email or Google)
    if (user.providerData.isNotEmpty) {
      String providerId = user.providerData[0].providerId;
      if (providerId == 'google.com') {
        return 'Google';
      } else if (providerId == 'password') {
        return 'Email';
      }
    }
    return 'Chưa đăng nhập';
  }

  IconData _getAuthProviderIcon(User? user) {
    if (user == null) return Icons.person; // Default icon when not logged in
    if (user.providerData.isNotEmpty) {
      String providerId = user.providerData[0].providerId;
      if (providerId == 'google.com') {
        return FontAwesomeIcons.google; // Google icon for Google login
      } else if (providerId == 'password') {
        return Icons.email; // Email icon for email login
      }
    }
    return Icons.person; // Default icon when not logged in
  }

  Widget _buildOverviewSection(User? user) {
    return _SingleSection(
      title: "Tổng quan",
      children: [
        _CustomListTile(
          title: "Nhà hàng của bạn",
          icon: Icons.store,
          onTap: () {
            if (user == null) {
              showToast("Bạn cần đăng nhập để truy cập");
            } else {
              Navigator.pushNamed(context, '/restaurant-owner');
            }
          },
        ),
        _CustomListTile(
          title: "Danh sách mã đặt bàn",
          icon: Icons.list_alt_rounded,
          onTap: () {
            if (user == null) {
              showToast("Bạn cần đăng nhập để truy cập");
            } else {
              Navigator.pushNamed(context, '/reservations');
            }
          },
        ),
        const _CustomListTile(
          title: "Trợ giúp",
          icon: Icons.help_outline_rounded,
        ),
        const _CustomListTile(
          title: "Về chúng tôi",
          icon: Icons.info_outline_rounded,
        ),
      ],
    );
  }

  Widget _buildAccountActionsSection(User? user) {
    return _SingleSection(
      title: "Tài khoản",
      children: user != null
          ? [
              _CustomListTile(
                title: "Đăng xuất",
                icon: Icons.exit_to_app_rounded,
                onTap: () async {
                  await FirebaseAuthServices().signOut();
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              title!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ...children,
      ],
    );
  }
}
