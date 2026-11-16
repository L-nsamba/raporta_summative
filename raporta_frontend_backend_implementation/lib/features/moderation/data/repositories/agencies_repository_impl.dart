import 'package:raporta_frontend_backend_implementation/features/moderation/data/datasources/agencies_remote_datasource.dart';

import '../../domain/entities/agency.dart';
import '../../domain/repositories/agencies_repository.dart';

class AgenciesRepositoryImpl implements AgenciesRepository {
  final AgenciesRemoteDataSource remoteDataSource;

  AgenciesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Agency>> getAgencies() {
    return remoteDataSource.getAgencies();
  }
}
