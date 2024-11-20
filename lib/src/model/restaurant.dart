class Restaurant{
  final String restaurantId;
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
  List<String> selectedImage;
  final Map<String, Map<String, String>> openCloseTimes;
  final String ownerId;
  final String type;
  final int createdAt;
  final int updatedAt;

  Restaurant({
    required this.restaurantId,
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
    required this.ownerId,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  // Hàm chuyển đổi model thành Map để lưu vào Firebase
  Map<String, dynamic> toMap() {
    return {
      'restaurantId': restaurantId,
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
      'ownerID': ownerId,
    };
  }
}
