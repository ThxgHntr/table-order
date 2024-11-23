import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:table_order/src/views/restaurant_view/restaurant_item_details_view.dart';

class RestaurantItemListView extends StatefulWidget {
  const RestaurantItemListView({super.key});

  static const routeName = '/';

  @override
  State<StatefulWidget> createState() => _RestaurantItemListViewState();
}

class _RestaurantItemListViewState extends State<RestaurantItemListView> {
  @override
  Widget build(BuildContext context) {
    final Query restaurantRef = FirebaseDatabase.instance
        .ref()
        .child("restaurants")
        .orderByChild("type")
        .equalTo("1");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nhà hàng gần bạn',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(7),
          child: SizedBox(height: 7),
        ),
      ),
      body: StreamBuilder(
        stream: restaurantRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Đã xảy ra lỗi!"));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Không có nhà hàng nào."));
          }

          final Map<dynamic, dynamic> restaurants =
          (snapshot.data!.snapshot.value as Map<dynamic, dynamic>)
              .map((key, value) => MapEntry(key, value))
              .cast<String, dynamic>();

          final restaurantList = restaurants.entries.toList();

          return ResponsiveBuilder(
            builder: (context, sizingInformation) {
              int crossAxisCount = 2; // Số cột mặc định

              if (sizingInformation.isDesktop) {
                crossAxisCount = 4;
              } else if (sizingInformation.isTablet) {
                crossAxisCount = 3;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: restaurantList.length,
                itemBuilder: (context, index) {
                  final entry = restaurantList[index];
                  final restaurantId = entry.key;
                  final restaurantData = entry.value;

                  final restaurantName =
                      restaurantData['restaurantName'] ?? 'Không có tên';
                  final imageUrl = (restaurantData['selectedImage'] as List?)
                      ?.firstWhere((img) => img != null, orElse: () => null) ??
                      'https://via.placeholder.com/150';

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 5,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantItemDetailsView(
                              restaurantId: restaurantId,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8.0)),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              restaurantName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.location_on, size: 16),
                                    SizedBox(width: 4),
                                    Text('20 km'),
                                  ],
                                ),
                                Row(
                                  children: const [
                                    Icon(Icons.star,
                                        size: 16, color: Colors.yellow),
                                    Text('5.0'),
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
              );
            },
          );
        },
      ),
    );
  }
}
