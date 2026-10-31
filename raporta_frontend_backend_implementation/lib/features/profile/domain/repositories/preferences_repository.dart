import 'package:raporta_frontend_backend_implementation/features/profile/domain/entities/user_preferences.dart';

abstract class PreferencesRepository {
  // Retrieve saved preferences
  Future<UserPreferences> getPreferences();

  // Save updated preferences
  Future<void> savePreferences(UserPreferences preferences);
}
