import 'dart:convert';
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';
import 'package:rudhirakshapp/core/utils/api_logger.dart';

class PatientLabRequestService {
  static final GetStorage _storage = GetStorage();

  static String? _getToken() => _storage.read<String>('token');

  static Map<String, String> _jsonHeaders() {
    final token = _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  /// GET /api/patient-portal/lab-requests
  static Future<List<dynamic>> fetchLabRequests() async {
    final token = _getToken();
    if (token == null || token.isEmpty) {
      ApiLogger.info('[lab-requests] no auth token in storage — patient not logged in?');
      return [];
    }
    final uri = Uri.parse('${ApiConstants.baseUrl}/patient-portal/lab-requests');
    ApiLogger.req('GET', uri);
    try {
      final response = await http.get(uri, headers: _jsonHeaders());
      ApiLogger.res('GET', uri, response.statusCode, response.body);
      if (response.statusCode != 200) {
        return [];
      }
      final body = json.decode(response.body);
      final list = (body['data'] as List?) ?? [];
      return list;
    } catch (e, s) {
      ApiLogger.err('GET', uri, e, s);
      return [];
    }
  }

  /// Upload file to Supabase storage via /api/uploads/single, return publicUrl + fileName
  static Future<Map<String, dynamic>?> _uploadFile(File file) async {
    final token = _getToken();
    if (token == null || token.isEmpty) return null;

    final uri = Uri.parse('${ApiConstants.baseUrl}/uploads/single?bucket=documents');
    ApiLogger.req('POST', uri, body: 'file=${file.path}');
    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      ApiLogger.res('POST', uri, streamed.statusCode, body);
      if (streamed.statusCode != 200 && streamed.statusCode != 201) {
        return null;
      }
      final decoded = json.decode(body);
      final data = decoded['data'] ?? decoded;
      if (data['publicUrl'] == null) return null;
      return {
        'fileUrl': data['publicUrl'],
        'fileName': data['fileName'],
      };
    } catch (e, s) {
      ApiLogger.err('POST', uri, e, s);
      return null;
    }
  }

  /// Upload a lab report file in response to a lab-request:
  /// 1. Upload file → get fileUrl
  /// 2. PATCH /api/patient-portal/lab-requests/:id/upload with { fileUrl, fileName, notes }
  static Future<Map<String, dynamic>> uploadLabReport({
    required int labRequestId,
    required File file,
    String? notes,
  }) async {
    final fileSize = await file.length();
    if (fileSize > 10 * 1024 * 1024) {
      return {'success': false, 'message': 'File exceeds 10MB limit'};
    }

    final uploaded = await _uploadFile(file);
    if (uploaded == null) {
      return {'success': false, 'message': 'File upload failed'};
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/patient-portal/lab-requests/$labRequestId/upload');
    final body = <String, dynamic>{
      'fileUrl': uploaded['fileUrl'],
      if (uploaded['fileName'] != null) 'fileName': uploaded['fileName'],
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };
    ApiLogger.req('PATCH', uri, body: body);
    try {
      final response = await http.patch(
        uri,
        headers: _jsonHeaders(),
        body: json.encode(body),
      );
      ApiLogger.res('PATCH', uri, response.statusCode, response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      final decoded = json.decode(response.body);
      return {
        'success': false,
        'message': decoded['message'] ?? 'Failed to attach report',
      };
    } catch (e, s) {
      ApiLogger.err('PATCH', uri, e, s);
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
