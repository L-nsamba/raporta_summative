import 'package:raporta_frontend_backend_implementation/features/auth/domain/entities/app_user.dart';

// This file lists services the application expects

abstract class AuthRepository {
  // Returns a pure dart entity, only contains core business logic no JSON or serialization
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

  // Sign in with Google with areaId since every user must be assigned to an area (both existing or new users)
  Future<AppUser> signInWithGoogle({required String areaId});

  // Send email verification
  Future<void> sendEmailVerification();

  // Send password reset link
  Future<void> sendPasswordReset(String email);

  // Retrieve currently authenticated user
  Future<AppUser?> getCurrentUser();

  // Update editable account profile fields.
  Future<AppUser> updateProfile({required String name, required String areaId});

  // Login and logout change detections
  Stream<AppUser?> get authStateChanges;

  // Sign out
  Future<void> signOut();
}
