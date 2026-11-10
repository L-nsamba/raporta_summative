import '../entities/user_preferences.dart';
import '../repositories/preferences_repository.dart';

class SavePreferences {
  final PreferencesRepository repository;

  SavePreferences({required this.repository});

  Future<void> call(UserPreferences preferences) {
    return repository.savePreferences(preferences);
  }
}