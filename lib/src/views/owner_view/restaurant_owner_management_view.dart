import 'package:flutter/material.dart';

class RestaurantOwnerManagementView extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const RestaurantOwnerManagementView(
      {super.key, required this.restaurantId, required this.restaurantName});

  static const String routeName = '/owner/restaurant_management';

  @override
  State<StatefulWidget> createState() => _RestaurantOwnerManagementViewState();
}

class _RestaurantOwnerManagementViewState
    extends State<RestaurantOwnerManagementView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurantName),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              //hien thi popup chinh sua thong tin nha hang
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[
          _buildDashboardItem(Icons.table_bar, 'Bàn đã đặt'),
          _buildDashboardItem(Icons.star, 'Đánh giá'),
          _buildDashboardItem(Icons.help, 'Trung tâm Trợ giúp'),
          _buildDashboardItem(Icons.group, 'Quản lý nhân viên'),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(IconData icon, String title) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          // Handle navigation to other pages
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50.0),
            Text(title, style: TextStyle(fontSize: 16.0)),
          ],
        ),
      ),
    );
  }
}
