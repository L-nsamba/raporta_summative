import 'package:flutter_test/flutter_test.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/user_role.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/data/models/user_model.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/entities/app_user.dart';

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  AppUserModel? testUser;
  bool signOutCalled = false;

  String? receivedEmail;
  String? receivedPassword;
  String? receivedAreaId;

  @override
  Future<AppUserModel> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String areaId,
  }) async {
    receivedEmail = email;
    receivedPassword = password;
    receivedAreaId = areaId;

    return testUser!;
  }

  @override
  Future<AppUserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    receivedEmail = email;
    receivedPassword = password;

    return testUser!;
  }

  @override
  Future<AppUserModel> signInWithGoogle({required String areaId}) async {
    receivedAreaId = areaId;
    return testUser!;
  }

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordReset(String email) async {
    receivedEmail = email;
  }

  @override
  Future<AppUserModel?> getCurrentUser() async {
    return testUser;
  }

  @override
  Stream<AppUserModel?> get authStateChanges => Stream.value(testUser);

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }
}

void main() {
  late FakeAuthRemoteDataSource fakeDataSource;
  late AuthRepositoryImpl repository;
  late AppUserModel testUser;

  setUp(() {
    fakeDataSource = FakeAuthRemoteDataSource();

    testUser = AppUserModel(
      userId: 'test-user-123',
      name: 'Test Citizen',
      email: 'citizen@example.com',
      role: UserRole.citizen,
      areaId: 'kimironko',
      createdAt: DateTime(2026, 11, 1),
      updatedAt: DateTime(2026, 11, 1),
    );

    fakeDataSource.testUser = testUser;

    repository = AuthRepositoryImpl(remoteDataSource: fakeDataSource);
  });

  test('registerWithEmail delegates correct details to data source', () async {
    final result = await repository.registerWithEmail(
      name: 'Test Citizen',
      email: 'citizen@example.com',
      password: 'testPassword123',
      areaId: 'kimironko',
    );

    expect(result.userId, 'test-user-123');
    expect(fakeDataSource.receivedEmail, 'citizen@example.com');
    expect(fakeDataSource.receivedAreaId, 'kimironko');
  });

  test('signInWithEmail delegates credentials to data source', () async {
    final result = await repository.signInWithEmail(
      email: 'citizen@example.com',
      password: 'testPassword123',
    );

    expect(result.email, 'citizen@example.com');
    expect(fakeDataSource.receivedEmail, 'citizen@example.com');
    expect(fakeDataSource.receivedPassword, 'testPassword123');
  });

  test('signInWithGoogle passes the selected area', () async {
    final result = await repository.signInWithGoogle(areaId: 'remera');

    expect(result.areaId, 'kimironko');
    expect(fakeDataSource.receivedAreaId, 'remera');
  });

  test('getCurrentUser returns the current user', () async {
    final AppUser? result = await repository.getCurrentUser();

    expect(result, isNotNull);
    expect(result!.userId, 'test-user-123');
  });

  test('signOut delegates to remote data source', () async {
    await repository.signOut();

    expect(fakeDataSource.signOutCalled, isTrue);
  });
}
