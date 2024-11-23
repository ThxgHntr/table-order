import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  final String name;
  final String email;
  final String phone;
  final String role;
  final List<String> permissions;
  final Timestamp hireDate;
  final String status;
  final double salary;
  final String profilePicture;
  final Timestamp createdAt;

  EmployeeModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.permissions,
    required this.hireDate,
    required this.status,
    required this.salary,
    required this.profilePicture,
    required this.createdAt,
  });

  factory EmployeeModel.fromFirestore(DocumentSnapshot data) {
    return EmployeeModel(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? '',
      permissions: List<String>.from(data['permissions'] ?? []),
      hireDate: data['hireDate'] ?? Timestamp.now(),
      status: data['status'] ?? 'active',
      salary: data['salary']?.toDouble() ?? 0.0,
      profilePicture: data['profilePicture'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'permissions': permissions,
      'hireDate': hireDate,
      'status': status,
      'salary': salary,
      'profilePicture': profilePicture,
      'created_at': createdAt,
    };
  }
}
