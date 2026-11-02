import 'package:raporta_frontend_backend_implementation/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/entities/app_user.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/repositories/auth_repository.dart';

// This file is the coordinator between the services the app expects, and the Firebase operations 

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  // Implementing email registration
  @override
  Future<AppUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String areaId,
  }) async {
    return remoteDataSource.registerWithEmail(
      name: name,
      email: email,
      password: password,
      areaId: areaId,
    );
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await remoteDataSource.signInWithEmail(
      email: email,
      password: password,
    );
  }

  // Implementing google sign in
  @override
  Future<AppUser> signInWithGoogle({required String areaId}) async {
    return await remoteDataSource.signInWithGoogle(areaId: areaId);
  }

  // Implementing email verification
  @override
  Future<void> sendEmailVerification() async {
    await remoteDataSource.sendEmailVerification();
  }

  // Implementing password reset
  @override
  Future<void> sendPasswordReset(String email) async {
    await remoteDataSource.sendPasswordReset(email);
  }

  // Implementing the current user retrieval
  @override
  Future<AppUser?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }

  // Implementing authentication state changes
  @override
  Stream<AppUser?> get authStateChanges => remoteDataSource.authStateChanges;

  // Implementing sign out
  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }
}
