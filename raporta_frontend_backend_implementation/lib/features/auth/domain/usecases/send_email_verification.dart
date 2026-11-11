import '../repositories/auth_repository.dart';

class SendEmailVerification {
  final AuthRepository repository;

  SendEmailVerification(this.repository);

  Future<void> call() {
    return repository.sendEmailVerification();
  }
}