import 'package:flutter/material.dart';
import 'package:table_order/src/views/owner_view/restaurant_owner_tab1_view.dart';
import 'package:table_order/src/views/owner_view/restaurant_owner_tab2_view.dart';

class RestaurantOwnerPageView extends StatefulWidget {
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
          title: Text('Danh sách nhà hàng',
              style: Theme.of(context).textTheme.headlineSmall),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Đăng ký nhà hàng',
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
                      'Tạo nhà hàng mới',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const TabBar(
                tabs: [
                  Tab(text: 'Nhà hàng của tôi'),
                  Tab(text: 'Nhà hàng đã đăng ký'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    RestaurantOwnerTab1View(),
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
