import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_preferences.dart';
import '../../domain/usecases/get_preferences.dart';
import '../../domain/usecases/save_preferences.dart';

import 'preferences_state.dart';

class PreferencesCubit extends Cubit<PreferencesState> {
  final GetPreferences getPreferences;
  final SavePreferences savePreferences;

  PreferencesCubit({
    required this.getPreferences,
    required this.savePreferences,
  }) : super(const PreferencesState());

  Future<void> loadPreferences() async {
    emit(state.copyWith(status: PreferencesStatus.loading));

    try {
      final preferences = await getPreferences();

      emit(
        PreferencesState(
          status: PreferencesStatus.loaded,
          preferences: preferences,
        ),
      );
    } catch (error) {
      emit(
        PreferencesState(
          status: PreferencesStatus.failure,
          preferences: state.preferences,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    final updated = UserPreferences(
      notificationsEnabled: enabled,
      isDarkMode: state.preferences.isDarkMode,
      defaultAreaId: state.preferences.defaultAreaId,
    );

    await _save(updated);
  }

  Future<void> updateDarkMode(bool enabled) async {
    final updated = UserPreferences(
      notificationsEnabled: state.preferences.notificationsEnabled,
      isDarkMode: enabled,
      defaultAreaId: state.preferences.defaultAreaId,
    );

    await _save(updated);
  }

  Future<void> updateDefaultArea(String? areaId) async {
    final updated = UserPreferences(
      notificationsEnabled: state.preferences.notificationsEnabled,
      isDarkMode: state.preferences.isDarkMode,
      defaultAreaId: areaId,
    );

    await _save(updated);
  }

  Future<void> _save(UserPreferences updated) async {
    if (state.status == PreferencesStatus.saving) return;

    final previous = state.preferences;

    emit(
      PreferencesState(status: PreferencesStatus.saving, preferences: previous),
    );

    try {
      await savePreferences(updated);

      emit(
        PreferencesState(
          status: PreferencesStatus.loaded,
          preferences: updated,
        ),
      );
    } catch (error) {
      emit(
        PreferencesState(
          status: PreferencesStatus.failure,
          preferences: previous,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
