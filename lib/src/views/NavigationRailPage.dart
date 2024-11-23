import 'package:flutter/material.dart';
import 'package:table_order/src/utils/location_helper.dart';
import 'package:table_order/src/utils/text_handle.dart';
import 'package:table_order/src/views/restaurant_view/restaurant_item_list_view.dart';
import 'package:table_order/src/views/user_view/notify_page_view.dart';
import 'package:table_order/src/views/user_view/profile_page_view.dart';
import '../settings/settings_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class NavigationRailPage extends StatefulWidget {
  const NavigationRailPage({super.key});

  @override
  State<NavigationRailPage> createState() => _NavigationRailPageState();
}

const _navBarItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home_rounded),
    label: 'Trang chủ',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.notifications_none_rounded),
    activeIcon: Icon(Icons.notifications_rounded),
    label: 'Thông báo',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.person_outline_rounded),
    activeIcon: Icon(Icons.person_rounded),
    label: 'Người dùng',
  ),
];

class _NavigationRailPageState extends State<NavigationRailPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const RestaurantItemListView(), // Trang Home
    const NotifyPageView(), // Trang Bookmarks
    const ProfilePageView(), // Trang Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String? locationText;
  Position? currentPosition;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isSmallScreen = width < 600;
    final bool isLargeScreen = width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logo here'),
        automaticallyImplyLeading: false,
        actions: [
          Text(
            locationText ?? '',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.location_pin),
            onPressed: () async {
              Position? currentPosition = await getCurrentLocation();
              if (currentPosition != null) {
                List<Placemark> placemarks = await placemarkFromCoordinates(
                  currentPosition.latitude,
                  currentPosition.longitude,
                );
                if (placemarks.isNotEmpty) {
                  Placemark place = placemarks.first;
                  String address = '${place.street}, ${place.subLocality}, '
                      '${place.locality}, ${place.country}';
                  setState(() {
                    locationText = truncateWithEllipsis(15, address);
                  });
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      bottomNavigationBar: isSmallScreen
          ? BottomNavigationBar(
              items: _navBarItems,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            )
          : null,
      body: Row(
        children: <Widget>[
          if (!isSmallScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              extended: isLargeScreen,
              destinations: _navBarItems
                  .map((item) => NavigationRailDestination(
                      icon: item.icon,
                      selectedIcon: item.activeIcon,
                      label: Text(item.label!)))
                  .toList(),
            ),
          const VerticalDivider(thickness: 1, width: 1),
          // Hiển thị trang tương ứng dựa trên lựa chọn
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}
