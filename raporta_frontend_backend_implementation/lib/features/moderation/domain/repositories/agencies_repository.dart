import '../entities/agency.dart';

abstract class AgenciesRepository {
  Future<List<Agency>> getAgencies();
}
