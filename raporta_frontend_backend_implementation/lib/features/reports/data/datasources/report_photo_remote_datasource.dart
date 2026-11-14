import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:raporta_frontend_backend_implementation/core/constants/cloudinary_config.dart';

abstract class ReportPhotoRemoteDataSource {
  Future<String> uploadPhoto(String filePath);
}

class ReportPhotoRemoteDataSourceImpl implements ReportPhotoRemoteDataSource {
  final http.Client client;

  ReportPhotoRemoteDataSourceImpl({required this.client});

  @override
  Future<String> uploadPhoto(String filePath) async {
    final file = File(filePath);

    // Make sure the selected image still exists.
    if (!await file.exists()) {
      throw StateError('The selected image does not exist.');
    }

    // Validate the image size.
    final fileSize = await file.length();

    if (fileSize > CloudinaryConfig.maxFileSize) {
      throw StateError('The selected image exceeds the 5 MB limit.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(CloudinaryConfig.uploadUrl),
    );

    // Cloudinary unsigned upload configuration.
    request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;

    // Attach the selected image.
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    // Send the request.
    final streamedResponse = await client
        .send(request)
        .timeout(const Duration(seconds: 60));

    final response = await http.Response.fromStream(streamedResponse)
        .timeout(const Duration(seconds: 30));

    // Check whether the upload succeeded.
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Image upload failed (${response.statusCode}).');
    }

    final data = jsonDecode(response.body);

    final secureUrl = data['secure_url'];

    if (secureUrl is! String || secureUrl.isEmpty) {
      throw const FormatException(
        'Cloudinary did not return a valid image URL.',
      );
    }

    return secureUrl;
  }
}
