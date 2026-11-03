import 'package:raporta_frontend_backend_implementation/features/areas/data/models/area_model.dart';

abstract class AreasRemoteDataSource {
  Future<List<AreaModel>> getAreas();

  Future<AreaModel?> getAreaById(String areaId);
}
