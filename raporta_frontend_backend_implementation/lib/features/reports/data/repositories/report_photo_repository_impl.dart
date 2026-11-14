import 'package:raporta_frontend_backend_implementation/features/reports/data/datasources/report_photo_remote_datasource.dart';

import '../../domain/repositories/report_photo_repository.dart';

class ReportPhotoRepositoryImpl implements ReportPhotoRepository {
  final ReportPhotoRemoteDataSource remoteDataSource;

  ReportPhotoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> uploadPhoto(String filePath) {
    return remoteDataSource.uploadPhoto(filePath);
  }
}
