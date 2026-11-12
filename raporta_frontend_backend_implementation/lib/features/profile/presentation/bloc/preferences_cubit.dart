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

  Future<void> loadPreferences() {
    final operation = _pendingUpdate.then((_) async {
      if (isClosed) return;

      emit(state.copyWith(status: PreferencesStatus.loading));

      try {
        final preferences = await getPreferences();

        if (isClosed) return;

        emit(
          PreferencesState(
            status: PreferencesStatus.loaded,
            preferences: preferences,
          ),
        );
      } catch (error) {
        if (isClosed) return;

        emit(
          PreferencesState(
            status: PreferencesStatus.failure,
            preferences: state.preferences,
            errorMessage: error.toString(),
          ),
        );
      }
    });

    _pendingUpdate = operation;
    return operation;
  }

  Future<void> _pendingUpdate = Future<void>.value();

  Future<void> _enqueueUpdate(
    UserPreferences Function(UserPreferences current) transform,
  ) {
    final operation = _pendingUpdate.catchError((Object _) {}).then((_) async {
      if (isClosed) return;

      final previous = state.preferences;
      final updated = transform(previous);

      emit(
        state.copyWith(status: PreferencesStatus.saving, preferences: updated),
      );

      try {
        await savePreferences(updated);

        if (isClosed) return;

        emit(
          state.copyWith(
            status: PreferencesStatus.loaded,
            preferences: updated,
          ),
        );
      } catch (error) {
        if (isClosed) return;

        emit(
          state.copyWith(
            status: PreferencesStatus.failure,
            preferences: previous,
            errorMessage: error.toString(),
          ),
        );
      }
    });

    _pendingUpdate = operation;
    return operation;
  }

  Future<void> updateNotificationsEnabled(bool enabled) {
    return _enqueueUpdate(
      (current) => UserPreferences(
        notificationsEnabled: enabled,
        isDarkMode: current.isDarkMode,
        defaultAreaId: current.defaultAreaId,
      ),
    );
  }

  Future<void> updateDarkMode(bool enabled) {
    return _enqueueUpdate(
      (current) => UserPreferences(
        notificationsEnabled: current.notificationsEnabled,
        isDarkMode: enabled,
        defaultAreaId: current.defaultAreaId,
      ),
    );
  }

  Future<void> updateDefaultArea(String? areaId) {
    return _enqueueUpdate(
      (current) => UserPreferences(
        notificationsEnabled: current.notificationsEnabled,
        isDarkMode: current.isDarkMode,
        defaultAreaId: areaId,
      ),
    );
  }
}
