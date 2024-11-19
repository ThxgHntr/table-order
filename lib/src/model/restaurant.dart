class Restaurant{
  final String restaurantName;
  final String restaurantCity;
  final String restaurantDistrict;
  final String restaurantWard;
  final String restaurantStreet;
  final String restaurantOwnerName;
  final String restaurantPhone;
  final String restaurantEmail;
  final String restaurantDescription;
  final List<String> selectedKeywords;
  final dynamic selectedImage;
  final Map<String, Map<String, String>> openCloseTimes;
  final String userId;

  Restaurant({
    required this.restaurantName,
    required this.restaurantCity,
    required this.restaurantDistrict,
    required this.restaurantWard,
    required this.restaurantStreet,
    required this.restaurantOwnerName,
    required this.restaurantPhone,
    required this.restaurantEmail,
    required this.restaurantDescription,
    required this.selectedKeywords,
    required this.selectedImage,
    required this.openCloseTimes,
    required this.userId,
  });

  // Hàm chuyển đổi model thành Map để lưu vào Firebase
  Map<String, dynamic> toMap() {
    return {
      'restaurantName': restaurantName,
      'restaurantCity': restaurantCity,
      'restaurantDistrict': restaurantDistrict,
      'restaurantWard': restaurantWard,
      'restaurantStreet': restaurantStreet,
      'restaurantOwnerName': restaurantOwnerName,
      'restaurantPhone': restaurantPhone,
      'restaurantEmail': restaurantEmail,
      'restaurantDescription': restaurantDescription,
      'selectedKeywords': selectedKeywords,
      'selectedImage': selectedImage,
      'openCloseTimes': openCloseTimes,
      'ownerID': userId,
      'type': '0', // 0: Chờ duyệt, 1: Đã duyệt, 2: Từ chối
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
