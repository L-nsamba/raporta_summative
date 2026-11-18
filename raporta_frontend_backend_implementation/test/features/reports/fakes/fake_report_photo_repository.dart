import 'package:raporta_frontend_backend_implementation/features/reports/domain/repositories/report_photo_repository.dart';

import 'dart:async';

class FakeReportPhotoRepository implements ReportPhotoRepository {
  String uploadedPhotoUrl =
      'https://res.cloudinary.com/demo/image/upload/report.jpg';

  bool shouldThrowError = false;

  int uploadPhotoCallCount = 0;
  String? lastUploadedFilePath;

  Completer<String>? uploadCompleter;

  @override
  Future<String> uploadPhoto(String filePath) async {
    uploadPhotoCallCount++;
    lastUploadedFilePath = filePath;

    if (shouldThrowError) {
      throw Exception('Failed to upload photo');
    }

    if (uploadCompleter != null) {
      return uploadCompleter!.future;
    }

    return uploadedPhotoUrl;
  }
}
