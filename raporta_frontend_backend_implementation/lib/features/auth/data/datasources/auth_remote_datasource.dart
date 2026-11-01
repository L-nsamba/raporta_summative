import 'package:firebase_auth/firebase_auth.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<AppUserModel> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String areaId,
  });

  Future<AppUserModel> signInWithEmail({
    required String email,
    required String password,
  });

  // AreaId required since both first time users and existing users will have to have provided it at one point
  Future<AppUserModel> signInWithGoogle({required String areaId});

  Future<void> sendEmailVerification();

  Future<void> sendPasswordReset(String email);

  Future<AppUserModel?> getCurrentUser();

  Stream<User?> get authStateChanges;

  Future<void> signOut();
}
