import 'dart:io';
//Login form validation
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Vui lòng nhập mật khẩu';
  } else if (value.length < 8) {
    return 'Mật khẩu phải có ít nhất 8 ký tự';
  } else {
    return null;
  }
}

//Sign up form validation
String? validateConfirmPassword(String? value, String password) {
  if (value == null || value.isEmpty) {
    return 'Vui lòng nhập mật khẩu';
  } else if (value != password) {
    return 'Mật khẩu không khớp';
  } else {
    return null;
  }
}

String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Vui lòng nhập tên';
  } else if (value.length < 5) {
    return 'Tên phải có ít nhất 5 ký tự';
  } else {
    return null;
  }
}

//Basic restaurant form validation
String? validateRestaurantName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Vui lòng nhập tên nhà hàng';
  } else if (value.length < 5) {
    return 'Tên nhà hàng phải có ít nhất 5 ký tự';
  } else if (value.length > 50) {
    return 'Tên nhà hàng không được quá 50 ký tự';
  } else {
    return null;
  }
}

String? validateRestaurantAddress(String? value) {
  if (value == null || value.isEmpty) {
    return 'Vui lòng nhập địa chỉ';
  } else {
    return null;
  }
}

//Restaurant representative form validation
String? validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'Vui lòng nhập số điện thoại';
  }
  final numericRegex = RegExp(r'^[0-9]+$');
  if (!numericRegex.hasMatch(value)) {
    return 'Số điện thoại chỉ được chứa số';
  }
  if (value.length < 10 || value.length > 11) {
    return 'Số điện thoại phải có 10 hoặc 11 số';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Vui lòng nhập email';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Email không hợp lệ';
  }
  return null;
}

//Restaurant details form validation
String? validateTime(String? value) {
  if (value == null || value.isEmpty) {
    return 'Vui lòng chọn giờ';
  }
  return null;
}

String? validateDescription(String? value) {
  if (value == null || value.isEmpty) {
    return 'Vui lòng nhập mô tả nhà hàng';
  }
  return null;
}

String? validatePrice(String? value) {
  if (value == null || value.isEmpty) {
    return 'Vui lòng nhập giá';
  }
  final price = double.tryParse(value);
  if (price == null || price <= 0) {
    return 'Giá không hợp lệ';
  }
  return null;
}

String? validateOpeningDays(Map<String, bool> isOpened) {
  if (isOpened.values.every((isOpen) => !isOpen)) {
    return 'Vui lòng chọn ít nhất một ngày mở cửa';
  }
  return null;
}

String? validateImages(List<File> images) {
  if (images.isEmpty) {
    return 'Vui lòng chọn ít nhất một ảnh';
  }
  return null;
}

String? validateKeywords(List<String> keywords) {
  if (keywords.isEmpty) {
    return 'Vui lòng chọn ít nhất một từ khóa';
  }
  return null;
}