import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_preferences.dart';

abstract class PreferencesLocalDatasource {
  Future<UserPreferences> getPreferences();
  Future<void> savePreferences(UserPreferences preferences);
}

class PreferencesLocalDatasourceImpl implements PreferencesLocalDatasource {
  final SharedPreferencesAsync preferences;
  final FirebaseAuth firebaseAuth;

  PreferencesLocalDatasourceImpl({
    required this.preferences,
    required this.firebaseAuth,
  });

  static const String _notificationsKey = 'notifications_enabled';
  static const String _darkModeKey = 'dark_mode';

  String? get _defaultAreaKey {
    final userId = firebaseAuth.currentUser?.uid;

    if (userId == null) return null;

    return 'default_area_id_$userId';
  }

  @override
  Future<UserPreferences> getPreferences() async {
    final areaKey = _defaultAreaKey;

    final notificationsEnabled =
        await preferences.getBool(_notificationsKey) ?? true;

    final isDarkMode = await preferences.getBool(_darkModeKey) ?? false;

    final defaultAreaId = areaKey == null
        ? null
        : await preferences.getString(areaKey);

    return UserPreferences(
      notificationsEnabled: notificationsEnabled,
      isDarkMode: isDarkMode,
      defaultAreaId: defaultAreaId,
    );
  }

  @override
  Future<void> savePreferences(UserPreferences userPreferences) async {
    final areaKey = _defaultAreaKey;

    await preferences.setBool(
      _notificationsKey,
      userPreferences.notificationsEnabled,
    );

    await preferences.setBool(_darkModeKey, userPreferences.isDarkMode);

    if (areaKey == null) {
      if (userPreferences.defaultAreaId != null) {
        throw StateError(
          'Cannot save a default area without an authenticated user.',
        );
      }
      return;
    }

    if (userPreferences.defaultAreaId == null) {
      await preferences.remove(areaKey);
    } else {
      await preferences.setString(areaKey, userPreferences.defaultAreaId!);
    }
  }
}
