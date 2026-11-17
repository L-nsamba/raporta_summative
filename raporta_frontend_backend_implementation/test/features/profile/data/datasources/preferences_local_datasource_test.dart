import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:raporta_frontend_backend_implementation/features/profile/data/datasources/preferences_local_datasource.dart';
import 'package:raporta_frontend_backend_implementation/features/profile/domain/entities/user_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAuth firebaseAuth;
  late MockFirebaseUser citizenA;
  late MockFirebaseUser citizenB;
  late SharedPreferencesAsync preferences;
  late PreferencesLocalDatasourceImpl dataSource;

  String? currentUserId;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    firebaseAuth = MockFirebaseAuth();
    citizenA = MockFirebaseUser();
    citizenB = MockFirebaseUser();

    currentUserId = null;

    when(() => citizenA.uid).thenReturn('citizen-a');
    when(() => citizenB.uid).thenReturn('citizen-b');

    when(() => firebaseAuth.currentUser).thenAnswer((_) {
      if (currentUserId == 'citizen-a') return citizenA;
      if (currentUserId == 'citizen-b') return citizenB;
      return null;
    });

    preferences = SharedPreferencesAsync();

    dataSource = PreferencesLocalDatasourceImpl(
      preferences: preferences,
      firebaseAuth: firebaseAuth,
    );
  });

  test('stores different default areas for different users', () async {
    currentUserId = 'citizen-a';

    await dataSource.savePreferences(
      const UserPreferences(
        notificationsEnabled: true,
        isDarkMode: false,
        defaultAreaId: 'area-1',
      ),
    );

    currentUserId = 'citizen-b';

    await dataSource.savePreferences(
      const UserPreferences(
        notificationsEnabled: true,
        isDarkMode: false,
        defaultAreaId: 'area-2',
      ),
    );

    currentUserId = 'citizen-a';
    final preferencesA = await dataSource.getPreferences();

    currentUserId = 'citizen-b';
    final preferencesB = await dataSource.getPreferences();

    expect(preferencesA.defaultAreaId, 'area-1');
    expect(preferencesB.defaultAreaId, 'area-2');
  });

  test('does not expose a users default area when signed out', () async {
    currentUserId = 'citizen-a';

    await dataSource.savePreferences(
      const UserPreferences(
        notificationsEnabled: true,
        isDarkMode: false,
        defaultAreaId: 'area-1',
      ),
    );

    currentUserId = null;

    final signedOutPreferences = await dataSource.getPreferences();

    expect(signedOutPreferences.defaultAreaId, isNull);
  });

  test('removing an area affects only the current user', () async {
    currentUserId = 'citizen-a';

    await dataSource.savePreferences(
      const UserPreferences(
        notificationsEnabled: true,
        isDarkMode: false,
        defaultAreaId: 'area-1',
      ),
    );

    currentUserId = 'citizen-b';

    await dataSource.savePreferences(
      const UserPreferences(
        notificationsEnabled: true,
        isDarkMode: false,
        defaultAreaId: 'area-2',
      ),
    );

    currentUserId = 'citizen-a';

    await dataSource.savePreferences(
      const UserPreferences(
        notificationsEnabled: true,
        isDarkMode: false,
        defaultAreaId: null,
      ),
    );

    final preferencesA = await dataSource.getPreferences();

    currentUserId = 'citizen-b';
    final preferencesB = await dataSource.getPreferences();

    expect(preferencesA.defaultAreaId, isNull);
    expect(preferencesB.defaultAreaId, 'area-2');
  });

  test('does not save an account area while signed out', () async {
    currentUserId = null;

    await expectLater(
      dataSource.savePreferences(
        const UserPreferences(
          notificationsEnabled: true,
          isDarkMode: false,
          defaultAreaId: 'area-1',
        ),
      ),
      throwsA(isA<StateError>()),
    );
  });
}