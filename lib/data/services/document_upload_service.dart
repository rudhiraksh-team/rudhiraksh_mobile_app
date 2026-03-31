import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';

class DocumentUploadService {
  static final GetStorage _storage = GetStorage();

  /// Upload a document (PDF/image) to patient portal
  /// Max file size: 2MB
  static Future<Map<String, dynamic>> uploadDocument({
    required File file,
    required String documentType,
    String? description,
  }) async {
    final token = _storage.read<String>('token');
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'No auth token'};
    }

    // Check file size (max 2MB)
    final fileSize = await file.length();
    if (fileSize > 2 * 1024 * 1024) {
      return {'success': false, 'message': 'File size exceeds 2MB limit'};
    }

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/patient-portal/documents');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      request.fields['documentType'] = documentType;
      if (description != null) {
        request.fields['description'] = description;
      }

      final streamedResponse = await request.send();
      await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        return {'success': true, 'message': 'Document uploaded successfully'};
      } else {
        return {'success': false, 'message': 'Upload failed (${streamedResponse.statusCode})'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Upload failed: $e'};
    }
  }
}
