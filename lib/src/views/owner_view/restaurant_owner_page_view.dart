import 'package:flutter/material.dart';
import 'package:table_order/src/views/owner_view/restaurant_owner_tab2_view.dart';

class RestaurantOwnerPageView extends StatefulWidget  {

  static const routeName = '/restaurant-owner';

  const RestaurantOwnerPageView({super.key});

  @override
  State<StatefulWidget> createState() => _RestaurantOwnerPageViewState();
}

class _RestaurantOwnerPageViewState extends State<RestaurantOwnerPageView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quán của bạn'),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Đăng ký quán',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/search-restaurant');
                  },
                  icon: Icon(Icons.add),
                  label: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Tạo quán mới',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const TabBar(
                tabs: [
                  Tab(text: 'Quán của tôi'),
                  Tab(text: 'Quán đã đăng ký'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Center(child: Text('Content for Tab 1')),
                    RestaurantOwnerTab2View(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}