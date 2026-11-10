import '../entities/agency.dart';
import '../repositories/agencies_repository.dart';

class GetAgencies {
  final AgenciesRepository repository;

  GetAgencies({required this.repository});

  Future<List<Agency>> call() {
    return repository.getAgencies();
  }
}
