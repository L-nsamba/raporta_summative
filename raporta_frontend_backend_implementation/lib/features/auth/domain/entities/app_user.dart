import 'package:raporta_frontend_backend_implementation/core/enums/user_role.dart';

class AppUser {
  final String userId;
  final String name;
  final String email;
  final UserRole role;
  final String areaId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.areaId,
    required this.createdAt,
    required this.updatedAt,
  });
}
