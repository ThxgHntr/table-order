import 'package:scoped_model/scoped_model.dart';

class Restaurant extends Model {
  final String name;
  final String imageLink;
  int rating;

  Restaurant({
    required this.name,
    required this.imageLink,
    required this.rating,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['name'],
      imageLink: json['imageLink'],
      rating: json['rating'],
    );
  }

  static getRestaurant() {
    List<Restaurant> items = <Restaurant>[];
    items.add(Restaurant(
        name: 'Restaurant 1',
        imageLink: 'assets/images/restaurant1.jpg',
        rating: 4));
    items.add(Restaurant(
        name: 'Restaurant 2',
        imageLink: 'assets/images/restaurant2.jpg',
        rating: 3));
    items.add(Restaurant(
        name: 'Restaurant 3',
        imageLink: 'assets/images/restaurant3.jpg',
        rating: 5));
    items.add(Restaurant(
        name: 'Restaurant 4',
        imageLink: 'assets/images/restaurant4.jpg',
        rating: 2));
    items.add(Restaurant(
        name: 'Restaurant 5',
        imageLink: 'assets/images/restaurant5.jpg',
        rating: 4));

    return items; // Trả về danh sách các nhà hàng
  }
}
