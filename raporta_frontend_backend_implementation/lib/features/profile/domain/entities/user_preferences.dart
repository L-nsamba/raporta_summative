class UserPreferences {
  final bool notificationsEnabled;
  final bool isDarkMode;
  final String? defaultAreaId;

  const UserPreferences({
    required this.notificationsEnabled,
    required this.isDarkMode,
    this.defaultAreaId,
  });
}
