import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_preferences.dart';

abstract class PreferencesLocalDatasource {
  Future<UserPreferences> getPreferences();
  Future<void> savePreferences(UserPreferences preferences);
}

class PreferencesLocalDatasourceImpl implements PreferencesLocalDatasource {
  final SharedPreferencesAsync preferences;

  PreferencesLocalDatasourceImpl({required this.preferences});

  static const String _notificationsKey = 'notifications_enabled';
  static const String _darkModeKey = 'dark_mode';
  static const String _defaultAreaKey = 'default_area_id';

  @override
  Future<UserPreferences> getPreferences() async {
    final notificationsEnabled = await preferences.getBool(_notificationsKey) ?? true;
    final isDarkMode = await preferences.getBool(_darkModeKey) ?? false;
    final defaultAreaId = await preferences.getString(_defaultAreaKey);

    return UserPreferences(
      notificationsEnabled: notificationsEnabled,
      isDarkMode: isDarkMode,
      defaultAreaId: defaultAreaId,
    );
  }

  @override
  Future<void> savePreferences(UserPreferences userPreferences) async {
    await preferences.setBool(_notificationsKey, userPreferences.notificationsEnabled,);
    await preferences.setBool(_darkModeKey, userPreferences.isDarkMode);

    if (userPreferences.defaultAreaId == null) {
      await preferences.remove(_defaultAreaKey);
    } else {
      await preferences.setString(_defaultAreaKey, userPreferences.defaultAreaId!,);
    }
  }
}