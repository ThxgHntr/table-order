import 'package:flutter/material.dart';
import '../../sample_feature/sample_item_list_view.dart';
import '../../settings/settings_view.dart';

class NavigationRailPage extends StatefulWidget {
  const NavigationRailPage({super.key});

  @override
  State<NavigationRailPage> createState() => _NavigationRailPageState();
}

const _navBarItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home_rounded),
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.bookmark_border_outlined),
    activeIcon: Icon(Icons.bookmark_rounded),
    label: 'Bookmarks',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.person_outline_rounded),
    activeIcon: Icon(Icons.person_rounded),
    label: 'Profile',
  ),
];

class _NavigationRailPageState extends State<NavigationRailPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SampleItemListView(), // Trang Home
    Container(color: Colors.blue), // Trang Bookmarks
    Container(color: Colors.green), // Trang Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
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
        actions: [
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
