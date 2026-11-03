import 'package:raporta_frontend_backend_implementation/features/areas/domain/entities/area.dart';
import 'package:raporta_frontend_backend_implementation/features/areas/domain/repositories/areas_repository.dart';

class GetAreas {
  final AreasRepository repository;

  GetAreas(this.repository);

  Future<List<Area>> call() async {
    return await repository.getAreas();
  }
}
