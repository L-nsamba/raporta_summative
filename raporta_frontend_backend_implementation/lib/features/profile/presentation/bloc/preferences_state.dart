import '../../domain/entities/user_preferences.dart';

enum PreferencesStatus { initial, loading, loaded, saving, failure }

class PreferencesState {
  final PreferencesStatus status;
  final UserPreferences preferences;
  final String? errorMessage;

  const PreferencesState({
    this.status = PreferencesStatus.initial,
    this.preferences = const UserPreferences(
      notificationsEnabled: true,
      isDarkMode: false,
    ),
    this.errorMessage,
  });

  PreferencesState copyWith({
    PreferencesStatus? status,
    UserPreferences? preferences,
    String? errorMessage,
  }) {
    return PreferencesState(
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      errorMessage: errorMessage,
    );
  }
}
