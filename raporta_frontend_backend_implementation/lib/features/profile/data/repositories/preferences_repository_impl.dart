import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../datasources/preferences_local_datasource.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesLocalDatasource localDatasource;

  PreferencesRepositoryImpl({required this.localDatasource});

  @override
  Future<UserPreferences> getPreferences() {
    return localDatasource.getPreferences();
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) {
    return localDatasource.savePreferences(preferences);
  }
}
