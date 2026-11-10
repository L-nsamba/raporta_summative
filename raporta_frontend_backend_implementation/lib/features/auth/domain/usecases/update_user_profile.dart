import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfile {
  final AuthRepository repository;

  UpdateProfile({required this.repository});

  Future<AppUser> call({required String name, required String areaId}) {
    return repository.updateProfile(name: name, areaId: areaId);
  }
}