import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class RestaurantItemDetailsView extends StatefulWidget {
  const RestaurantItemDetailsView({super.key});

  static const routeName = '/sample_item';

  @override
  State<RestaurantItemDetailsView> createState() => _RestaurantItemDetailsViewState();
}

class _RestaurantItemDetailsViewState extends State<RestaurantItemDetailsView> {
  final int _current = 0;

  final List<String> imgList = [
    'https://via.placeholder.com/150',
    'https://via.placeholder.com/150',
    'https://via.placeholder.com/150',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tên nhà hàng ở đây'),
        //border bottom
        shape: const Border(
          bottom: BorderSide(
            color: Colors.deepOrange,
            width: 1,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            CarouselSlider(
              items: imgList
                  .map(
                    (item) => Center(
                  child: Image.network(
                    item,
                    fit: BoxFit.cover,
                    width: 1000,
                  ),
                ),
              )
                  .toList(),
              options: CarouselOptions(
                height: 170,
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.map((url) {
                int index = imgList.indexOf(url);
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == index
                        ? Color.fromRGBO(0, 0, 0, 0.9)
                        : Color.fromRGBO(0, 0, 0, 0.4),
                  ),
                );
              }).toList(),
            ),
            const Divider(
              height: 20,
              thickness: 2,
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16),
                    SizedBox(width: 4),
                    Text('123 Đường ABC, Quận XYZ, TP. HCM'), // Hiển thị khoảng cách
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.timer, size: 16),
                    SizedBox(width: 4),
                    Text('10:30 AM - 11:00 PM'), // Hiển thị khoảng cách
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.yellow),
                    Text('5.0'), // Hiển thị số sao
                    SizedBox(width: 4),
                    Text('(100 đánh giá)'), // Hiển thị số sao
                    //xem tất cả đánh giá
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/restaurant_review');
                      },
                      child: Text('Xem tất cả đánh giá'),
                    ),
                  ],
                ),
                //Mô tả
                Row(
                  children: [
                    Icon(Icons.description, size: 16),
                    SizedBox(width: 4),
                    Text('Mô tả: '),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Mô tả nhà hàng ở đây',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Vị trí đặt bàn ở đây',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
