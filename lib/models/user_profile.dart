import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.phone,
    required this.userType,
    required this.createdAt,
    this.role = 'user',
  });

  final String uid;
  final String name;
  final String phone;
  final String userType;
  final DateTime createdAt;
  final String role;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> d) {
    return UserProfile(
      uid: uid,
      name: (d['name'] ?? '').toString(),
      phone: (d['phone'] ?? '').toString(),
      userType: (d['userType'] ?? 'Resident').toString(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      role: (d['role'] ?? 'user').toString(),
    );
  }
}
