import 'package:flutter/material.dart';
import 'package:table_order/src/views/owner_view/restaurant_management_view/table_management_view.dart';

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
          _buildDashboardItem(Icons.pivot_table_chart_rounded, 'Quản lý bàn'),
          _buildDashboardItem(Icons.group, 'Quản lý nhân viên'),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(IconData icon, String title) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          if (title == 'Quản lý bàn') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TableManagementView(
                  restaurantId: widget.restaurantId,
                ),
              ),
            );
            /*Navigator.pushNamed(
              context,
              TableManagementView.routeName,
              arguments: {'restaurantId': widget.restaurantId},
            );*/
          }
          // Handle other navigation cases if needed
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50.0),
            Text(title, style: const TextStyle(fontSize: 16.0)),
          ],
        ),
      ),
    );
  }
}
