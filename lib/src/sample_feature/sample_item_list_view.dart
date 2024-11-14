import 'package:flutter/material.dart';

import 'sample_item.dart';
import 'sample_item_details_view.dart';

/// Displays a list of SampleItems.
class SampleItemListView extends StatelessWidget {
  const SampleItemListView({
    super.key,
    this.items = const [SampleItem(1), SampleItem(2), SampleItem(3)],
  });

  static const routeName = '/';

  final List<SampleItem> items;

  /*static const routeName = '/';
  const SampleItemListView({super.key, required this.items});
  final Restaurant items;*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nhà hàng gần bạn',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight
                    .bold, // Thêm fontWeight: FontWeight.bold để làm đậm
              ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(7), // Tạo khoảng cách dưới AppBar
          child: Container(
            padding: EdgeInsets.only(bottom: 7), // Thêm padding dưới
          ),
        ),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10, // Khoảng cách ngang giữa các Card
          mainAxisSpacing: 10, // Khoảng cách dọc giữa các Card
        ),
        restorationId: 'sampleItemListView',
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            elevation: 5, // Thêm bóng đổ cho Card
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  SampleItemDetailsView.routeName,
                  arguments: item,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Image.asset(
                      'assets/images/flutter_logo.png',
                      fit: BoxFit.cover,
                      width: double.infinity, // Chiếm toàn bộ chiều rộng
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'SampleItem ${item.id}', // Tên nhà hàng
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Cột bên trái: km
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16),
                            SizedBox(width: 4),
                            Text('20 km'), // Hiển thị khoảng cách
                          ],
                        ),
                        // Cột bên phải: 5 sao
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.yellow),
                            Text('5.0'), // Hiển thị số sao
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
