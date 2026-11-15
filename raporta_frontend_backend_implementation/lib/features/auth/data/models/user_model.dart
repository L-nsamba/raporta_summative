import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/user_role.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.userId,
    required super.name,
    required super.email,
    required super.role,
    required super.areaId,
    required super.createdAt,
    required super.updatedAt,
    super.emailVerified,
  });

  factory AppUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document, {
    bool emailVerified = false,
  }) {
    final data = document.data();

    if (data == null) {
      throw const FormatException('User document contains no data.');
    }

    return AppUserModel(
      emailVerified: emailVerified,
      userId: document.id,
      name: data['name'] as String,
      email: data['email'] as String,
      role: UserRole.values.byName(data['role'] as String),
      areaId: data['areaId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role.name,
      'areaId': areaId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
