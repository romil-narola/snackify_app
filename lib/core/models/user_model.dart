import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String employeeId;
  final String department;
  final String phone;
  final String role; // 'employee' or 'admin'
  final String profileImage;
  final bool isActive;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.employeeId,
    required this.department,
    required this.phone,
    required this.role,
    required this.profileImage,
    required this.isActive,
    required this.createdAt,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? employeeId,
    String? department,
    String? phone,
    String? role,
    String? profileImage,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      employeeId: employeeId ?? this.employeeId,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'employeeId': employeeId,
      'department': department,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      employeeId: map['employeeId'] ?? '',
      department: map['department'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'employee',
      profileImage: map['profileImage'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    uid,
    name,
    email,
    employeeId,
    department,
    phone,
    role,
    profileImage,
    isActive,
    createdAt,
  ];
}
