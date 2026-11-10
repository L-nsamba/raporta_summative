import '../entities/user_preferences.dart';
import '../repositories/preferences_repository.dart';

class GetPreferences {
  final PreferencesRepository repository;

  GetPreferences({required this.repository});

  Future<UserPreferences> call() {
    return repository.getPreferences();
  }
}