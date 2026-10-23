import 'dart:convert';
import 'dart:io';

import 'package:c2w_management_app/config/cloudinary_config.dart';
import 'package:http/http.dart' as http;

class CloudinaryDataSource {
  final http.Client _client;

  CloudinaryDataSource({http.Client? client})
    : _client = client ?? http.Client();

  Future<String> uploadReceipt({
    required String filePath,
    required String expenseId,
  }) async {
    return _uploadImage(
      filePath: filePath,
      folder: CloudinaryConfig.uploadFolder,
      publicId: expenseId,
      fileDescription: 'Receipt image',
    );
  }

  Future<String> uploadProfileImage({
    required String filePath,
    required String email,
  }) async {
    final encodedEmail = base64Url
        .encode(utf8.encode(email))
        .replaceAll('=', '');
    return _uploadImage(
      filePath: filePath,
      folder: CloudinaryConfig.profileImagesFolder,
      publicId:
          'profile_${encodedEmail}_${DateTime.now().microsecondsSinceEpoch}',
      fileDescription: 'Profile image',
    );
  }

  Future<String> _uploadImage({
    required String filePath,
    required String folder,
    required String publicId,
    required String fileDescription,
  }) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('$fileDescription was not found.');
    }

    final fileSize = await file.length();

    if (fileSize > CloudinaryConfig.maxFileSizeInBytes) {
      throw Exception('$fileDescription must be 10 MB or smaller.');
    }

    final extension = filePath.split('.').last.toLowerCase();

    if (!CloudinaryConfig.allowedFormats.contains(extension)) {
      throw Exception('Only JPG, JPEG, PNG, and WEBP images are allowed.');
    }

    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse(CloudinaryConfig.imageUploadUrl),
          )
          ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
          ..fields['folder'] = folder
          ..fields['public_id'] = publicId
          ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await _client.send(request);
    final responseBody = await response.stream.bytesToString();

    final responseData = jsonDecode(responseBody);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = responseData is Map<String, dynamic>
          ? responseData['error']
          : null;
      final errorMessage = error is Map<String, dynamic>
          ? error['message']
          : null;

      throw Exception(
        errorMessage?.toString() ?? '$fileDescription upload failed.',
      );
    }

    if (responseData is! Map<String, dynamic>) {
      throw Exception('Invalid response received from Cloudinary.');
    }

    final secureUrl = responseData['secure_url'] as String?;

    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary did not return an image URL.');
    }

    return secureUrl;
  }

  void dispose() {
    _client.close();
  }
}
