import 'package:raporta_frontend_backend_implementation/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  // Register a new citizen
  Future<AppUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String areaId,
  });

  // Sign in with email and password
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  // Sign in with Google
  Future<AppUser> signinWithGoogle();

  // Send email verification
  Future<void> sendEmailVerification();

  // Send password reset link
  Future<void> sendPasswordReset(String email);

  // Retrieve currently authenticated user
  Future<AppUser?> getCurrentUser();

  // Sign out
  Future<void> signOut();
}
