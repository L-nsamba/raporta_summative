import 'package:raporta_frontend_backend_implementation/features/areas/domain/entities/area.dart';

abstract class AreasRepository {
  // Retrieve all available areas
  Future<List<Area>> getArea();

  // Retrieve a specific area
  Future<Area?> getAreaById(String areaId);
}
