import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class RegisterWithEmail {
  final AuthRepository repository;

  RegisterWithEmail(this.repository);

  Future<AppUser> call({
    required String name,
    required String email,
    required String password,
    required String areaId,
  }) {
    return repository.registerWithEmail(
      name: name,
      email: email,
      password: password,
      areaId: areaId,
    );
  }
}
