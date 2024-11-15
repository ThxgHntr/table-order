import 'package:flutter/material.dart';
import 'package:table_order/src/utils/thanhPhoDropDown.dart';

class SearchRestaurant extends StatefulWidget {
  const SearchRestaurant({super.key});

  static const routeName = '/search-restaurant';

  @override
  State<SearchRestaurant> createState() => _SearchRestaurantState();
}

class _SearchRestaurantState extends State<SearchRestaurant> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm quán ăn'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            const TextField(
              decoration: InputDecoration(
                hintText: 'Nhập tên quán ăn',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 1),
              height: 110,
              //gom 1 hang 2 cot ben trai la dropdown ben phai la nut tim kiem
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ThanhPhoDropDown(),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Tìm kiếm'),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 20,
              thickness: 2,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kết quả tìm kiếm:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Không tìm thấy quán nào trùng khớp',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {

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
          ],
        ),
      )
    );
  }
}