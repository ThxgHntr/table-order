import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_order/src/utils/location_helper.dart';
import 'package:table_order/src/views/restaurant_view/restaurant_item_list_view.dart';
import 'package:table_order/src/views/user_view/notify_page_view.dart';
import 'package:table_order/src/views/user_view/profile_page_view.dart';
import '../settings/settings_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  late Key _restaurantItemListViewKey;
  FirebaseAuth auth = FirebaseAuth.instance;
  late List<Widget> _pages;
  String? locationText;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    _restaurantItemListViewKey = UniqueKey();
    _pages = [
      RestaurantItemListView(key: _restaurantItemListViewKey), // Trang Home
      const NotifyPageView(), // Trang Bookmarks
      const ProfilePageView(), // Trang Profile
    ];
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    Position? currentPosition = await getCurrentLocation();
    if (currentPosition != null) {
      Placemark? place = await getAddressFromCoordinates(currentPosition);
      setState(() {
        final width = MediaQuery.of(context).size.width;
        final bool isSmallScreen = width < 600;
        locationText = isSmallScreen
            ? '${place?.street}'
            : '${place?.street}, ${place?.administrativeArea}';
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser!.uid)
          .update({
        'location':
            GeoPoint(currentPosition.latitude, currentPosition.longitude),
      });
    }
  }

  Future<void> _refreshPage() async {
    setState(() {
      _restaurantItemListViewKey = UniqueKey();
      _pages[0] = RestaurantItemListView(key: _restaurantItemListViewKey);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex == 0 && index == 0) {
        // Change the key to force rebuild and reinitialize the state
        _restaurantItemListViewKey = UniqueKey();
        _pages[0] = RestaurantItemListView(key: _restaurantItemListViewKey);
      }
      _selectedIndex = index;
    });
  }

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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.location_pin),
            onPressed: () async {
              await _initializeLocation();
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
          // Hiển thị trang tương ứng dựa trên lựa chọn
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshPage,
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
