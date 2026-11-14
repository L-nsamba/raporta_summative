import '../repositories/report_photo_repository.dart';

class UploadReportPhoto {
  final ReportPhotoRepository repository;

  UploadReportPhoto({required this.repository});

  Future<String> call(String filePath) {
    return repository.uploadPhoto(filePath);
  }
}
