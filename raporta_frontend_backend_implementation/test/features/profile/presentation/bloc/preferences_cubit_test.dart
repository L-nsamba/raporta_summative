import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:raporta_frontend_backend_implementation/features/profile/domain/entities/user_preferences.dart';
import 'package:raporta_frontend_backend_implementation/features/profile/domain/usecases/get_preferences.dart';
import 'package:raporta_frontend_backend_implementation/features/profile/domain/usecases/save_preferences.dart';
import 'package:raporta_frontend_backend_implementation/features/profile/presentation/bloc/preferences_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/profile/presentation/bloc/preferences_state.dart';

class MockGetPreferences extends Mock implements GetPreferences {}

class MockSavePreferences extends Mock implements SavePreferences {}

void main() {
  late MockGetPreferences getPreferences;
  late MockSavePreferences savePreferences;

  const defaultPreferences = UserPreferences(
    notificationsEnabled: true,
    isDarkMode: false,
  );

  const savedPreferences = UserPreferences(
    notificationsEnabled: false,
    isDarkMode: true,
    defaultAreaId: 'area-1',
  );

  PreferencesCubit buildCubit() {
    return PreferencesCubit(
      getPreferences: getPreferences,
      savePreferences: savePreferences,
    );
  }

  setUpAll(() {
    registerFallbackValue(defaultPreferences);
  });

  setUp(() {
    getPreferences = MockGetPreferences();
    savePreferences = MockSavePreferences();

    when(() => getPreferences()).thenAnswer((_) async => defaultPreferences);

    when(() => savePreferences(any())).thenAnswer((_) async {});
  });

  test('initial state contains default preferences', () async {
    final cubit = buildCubit();

    expect(cubit.state.status, PreferencesStatus.initial);
    expect(cubit.state.preferences.notificationsEnabled, true);
    expect(cubit.state.preferences.isDarkMode, false);
    expect(cubit.state.preferences.defaultAreaId, null);

    await cubit.close();
  });

  blocTest<PreferencesCubit, PreferencesState>(
    'loads saved preferences successfully',
    build: () {
      when(() => getPreferences()).thenAnswer((_) async => savedPreferences);

      return buildCubit();
    },
    act: (cubit) => cubit.loadPreferences(),
    expect: () => [
      isA<PreferencesState>().having(
        (state) => state.status,
        'status',
        PreferencesStatus.loading,
      ),
      isA<PreferencesState>()
          .having((state) => state.status, 'status', PreferencesStatus.loaded)
          .having(
            (state) => state.preferences.notificationsEnabled,
            'notifications',
            false,
          )
          .having((state) => state.preferences.isDarkMode, 'dark mode', true)
          .having((state) => state.preferences.defaultAreaId, 'area', 'area-1'),
    ],
    verify: (_) {
      verify(() => getPreferences()).called(1);
    },
  );

  blocTest<PreferencesCubit, PreferencesState>(
    'emits failure when loading preferences fails',
    build: () {
      when(() => getPreferences()).thenThrow(Exception('Storage unavailable'));

      return buildCubit();
    },
    act: (cubit) => cubit.loadPreferences(),
    expect: () => [
      isA<PreferencesState>().having(
        (state) => state.status,
        'status',
        PreferencesStatus.loading,
      ),
      isA<PreferencesState>()
          .having((state) => state.status, 'status', PreferencesStatus.failure)
          .having(
            (state) => state.errorMessage,
            'error',
            contains('Storage unavailable'),
          ),
    ],
  );

  blocTest<PreferencesCubit, PreferencesState>(
    'updates notification preference successfully',
    build: buildCubit,
    act: (cubit) => cubit.updateNotificationsEnabled(false),
    expect: () => [
      isA<PreferencesState>().having(
        (state) => state.status,
        'status',
        PreferencesStatus.saving,
      ),
      isA<PreferencesState>()
          .having((state) => state.status, 'status', PreferencesStatus.loaded)
          .having(
            (state) => state.preferences.notificationsEnabled,
            'notifications',
            false,
          )
          .having((state) => state.preferences.isDarkMode, 'dark mode', false),
    ],
    verify: (_) {
      final saved =
          verify(() => savePreferences(captureAny())).captured.single
              as UserPreferences;

      expect(saved.notificationsEnabled, false);
      expect(saved.isDarkMode, false);
    },
  );

  blocTest<PreferencesCubit, PreferencesState>(
    'updates dark mode successfully',
    build: buildCubit,
    act: (cubit) => cubit.updateDarkMode(true),
    expect: () => [
      isA<PreferencesState>().having(
        (state) => state.status,
        'status',
        PreferencesStatus.saving,
      ),
      isA<PreferencesState>()
          .having((state) => state.status, 'status', PreferencesStatus.loaded)
          .having((state) => state.preferences.isDarkMode, 'dark mode', true),
    ],
    verify: (_) {
      final saved =
          verify(() => savePreferences(captureAny())).captured.single
              as UserPreferences;

      expect(saved.isDarkMode, true);
      expect(saved.notificationsEnabled, true);
    },
  );

  blocTest<PreferencesCubit, PreferencesState>(
    'updates default area successfully',
    build: buildCubit,
    act: (cubit) => cubit.updateDefaultArea('area-2'),
    expect: () => [
      isA<PreferencesState>().having(
        (state) => state.status,
        'status',
        PreferencesStatus.saving,
      ),
      isA<PreferencesState>()
          .having((state) => state.status, 'status', PreferencesStatus.loaded)
          .having(
            (state) => state.preferences.defaultAreaId,
            'default area',
            'area-2',
          ),
    ],
    verify: (_) {
      final saved =
          verify(() => savePreferences(captureAny())).captured.single
              as UserPreferences;

      expect(saved.defaultAreaId, 'area-2');
    },
  );

  blocTest<PreferencesCubit, PreferencesState>(
    'clears default area successfully',
    build: buildCubit,
    seed: () => const PreferencesState(
      status: PreferencesStatus.loaded,
      preferences: savedPreferences,
    ),
    act: (cubit) => cubit.updateDefaultArea(null),
    expect: () => [
      isA<PreferencesState>().having(
        (state) => state.status,
        'status',
        PreferencesStatus.saving,
      ),
      isA<PreferencesState>()
          .having((state) => state.status, 'status', PreferencesStatus.loaded)
          .having(
            (state) => state.preferences.defaultAreaId,
            'default area',
            null,
          ),
    ],
    verify: (_) {
      final saved =
          verify(() => savePreferences(captureAny())).captured.single
              as UserPreferences;

      expect(saved.defaultAreaId, null);
      expect(saved.isDarkMode, true);
      expect(saved.notificationsEnabled, false);
    },
  );

  blocTest<PreferencesCubit, PreferencesState>(
    'preserves previous preferences when saving fails',
    build: () {
      when(() => savePreferences(any())).thenThrow(Exception('Write failed'));

      return buildCubit();
    },
    act: (cubit) => cubit.updateDarkMode(true),
    expect: () => [
      isA<PreferencesState>().having(
        (state) => state.status,
        'status',
        PreferencesStatus.saving,
      ),
      isA<PreferencesState>()
          .having((state) => state.status, 'status', PreferencesStatus.failure)
          .having((state) => state.preferences.isDarkMode, 'dark mode', false)
          .having(
            (state) => state.errorMessage,
            'error message',
            contains('Write failed'),
          ),
    ],
  );
}