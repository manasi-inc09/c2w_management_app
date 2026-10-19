
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
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('Receipt image was not found.');
    }

    final fileSize = await file.length();

    if (fileSize > CloudinaryConfig.maxFileSizeInBytes) {
      throw Exception('Receipt image must be 10 MB or smaller.');
    }

    final extension = filePath.split('.').last.toLowerCase();

    if (!CloudinaryConfig.allowedFormats.contains(extension)) {
      throw Exception('Only JPG, JPEG, PNG, and WEBP images are allowed.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(CloudinaryConfig.imageUploadUrl),
    )
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..fields['folder'] = CloudinaryConfig.uploadFolder
      ..fields['public_id'] = expenseId
      ..files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );

    final response = await _client.send(request);
    final responseBody = await response.stream.bytesToString();

    final responseData = jsonDecode(responseBody);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorMessage = responseData is Map<String, dynamic>
          ? responseData['error']?['message']
          : null:null;

      throw Exception(
        errorMessage?.toString() ?? 'Receipt upload failed.',
      );
    }

    if (responseData is! Map<String, dynamic>) {
      throw Exception('Invalid response received from Cloudinary.');
    }

    final secureUrl = responseData['secure_url'] as String?;

    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary did not return a receipt URL.');
    }

    return secureUrl;
  }

  void dispose() {
    _client.close();
  }
}
