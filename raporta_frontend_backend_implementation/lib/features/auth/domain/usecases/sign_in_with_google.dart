import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  Future<AppUser> call({required String areaId}) {
    return repository.signInWithGoogle(areaId: areaId);
  }
}
