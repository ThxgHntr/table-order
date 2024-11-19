import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

class RestaurantModel extends Model {
  // Basic info
  final restaurantName = TextEditingController();
  final restaurantCity = TextEditingController();
  final restaurantDistrict = TextEditingController();
  final restaurantWard = TextEditingController();
  final restaurantStreet = TextEditingController();

  // Representative info
  final restaurantOwnerName = TextEditingController();
  final restaurantPhone = TextEditingController();
  final restaurantEmail = TextEditingController();

  // Restaurant details
  final openTimeControllers = {
    'Chủ nhật': TextEditingController(),
    'Thứ hai': TextEditingController(),
    'Thứ ba': TextEditingController(),
    'Thứ tư': TextEditingController(),
    'Thứ năm': TextEditingController(),
    'Thứ sáu': TextEditingController(),
    'Thứ bảy': TextEditingController(),
  };
  final closeTimeControllers = {
    'Chủ nhật': TextEditingController(),
    'Thứ hai': TextEditingController(),
    'Thứ ba': TextEditingController(),
    'Thứ tư': TextEditingController(),
    'Thứ năm': TextEditingController(),
    'Thứ sáu': TextEditingController(),
    'Thứ bảy': TextEditingController(),
  };
  final isOpened = {
    'Chủ nhật': false,
    'Thứ hai': false,
    'Thứ ba': false,
    'Thứ tư': false,
    'Thứ năm': false,
    'Thứ sáu': false,
    'Thứ bảy': false,
  };
  final restaurantDescription = TextEditingController();
  final selectedKeywords = <String>[];

  void completeRegistration() {
    // Logic to complete registration
    notifyListeners();
  }

  void reset() {
    // Logic to reset all controllers
    restaurantName.clear();
    restaurantCity.clear();
    restaurantDistrict.clear();
    restaurantWard.clear();
    restaurantStreet.clear();
    restaurantOwnerName.clear();
    restaurantPhone.clear();
    restaurantEmail.clear();
    restaurantDescription.clear();
    selectedKeywords.clear();
    isOpened.updateAll((key, value) => false);
    openTimeControllers.forEach((key, controller) => controller.clear());
    closeTimeControllers.forEach((key, controller) => controller.clear());
    notifyListeners();
  }
}