enum UserRole {
  citizen,
  official;

  String toFirestore() => name;

  static UserRole fromFirestore(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => throw FormatException('Unknown user role: $value'),
    );
  }
}
