import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String adminId;
  final String name;
  final String email;
  final String phone;
  final String role;
  final List<String> permissions;
  final List<String> assignedRestaurants;
  final Timestamp createdAt;
  final Timestamp lastLogin;
  final String status;

  AdminModel({
    required this.adminId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.permissions,
    required this.assignedRestaurants,
    required this.createdAt,
    required this.lastLogin,
    required this.status,
  });

  factory AdminModel.fromFirebase(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return AdminModel(
      adminId: snapshot.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? '',
      permissions: List<String>.from(data['permissions'] ?? []),
      assignedRestaurants: List<String>.from(data['assignedRestaurants'] ?? []),
      createdAt: data['created_at'] ?? Timestamp.now(),
      lastLogin: data['last_login'] ?? Timestamp.now(),
      status: data['status'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'permissions': permissions,
      'assignedRestaurants': assignedRestaurants,
      'created_at': createdAt,
      'last_login': lastLogin,
      'status': status,
    };
  }
}
