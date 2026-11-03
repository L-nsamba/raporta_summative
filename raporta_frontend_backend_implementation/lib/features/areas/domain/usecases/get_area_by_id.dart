import 'package:raporta_frontend_backend_implementation/features/areas/domain/entities/area.dart';
import 'package:raporta_frontend_backend_implementation/features/areas/domain/repositories/areas_repository.dart';

class GetAreaById {
  final AreasRepository repository;

  GetAreaById(this.repository);

  Future<Area?> call(String areaId) async {
    return await repository.getAreaById(areaId);
  }
}
