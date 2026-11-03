
import 'package:raporta_frontend_backend_implementation/features/areas/data/datasources/areas_remote_datasource.dart';
import 'package:raporta_frontend_backend_implementation/features/areas/domain/entities/area.dart';
import 'package:raporta_frontend_backend_implementation/features/areas/domain/repositories/areas_repository.dart';


class AreasRepositoryImpl implements AreasRepository {
  final AreasRemoteDataSource remoteDataSource;

  AreasRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<Area>> getAreas() async {
    return await remoteDataSource.getAreas();
  }

  @override
  Future<Area?> getAreaById(String areaId) async {
    return await remoteDataSource.getAreaById(areaId);
  }
}