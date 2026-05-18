import 'dart:convert';
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';
import 'package:rudhirakshapp/core/utils/api_logger.dart';

class DoctorService {
  static final GetStorage _storage = GetStorage();

  static String? _getToken() => _storage.read<String>('token');

  static Map<String, String> _headers() {
    final token = _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  /// GET /api/doctor/patients - Fetch assigned patients
  static Future<Map<String, dynamic>?> fetchAssignedPatients({
    int page = 1,
    int limit = 50,
  }) async {
    final token = _getToken();
    if (token == null || token.isEmpty) return null;

    final uri = Uri.parse('${ApiConstants.baseUrl}/doctor/patients').replace(
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    ApiLogger.req('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers());
      ApiLogger.res('GET', uri, response.statusCode, response.body);

      if (response.statusCode == 200) {
        _storage.write('doctor_patients_json', response.body);
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final cached = _storage.read<String>('doctor_patients_json');
        if (cached != null) return json.decode(cached) as Map<String, dynamic>;
        return null;
      }
    } catch (e, s) {
      ApiLogger.err('GET', uri, e, s);
      final cached = _storage.read<String>('doctor_patients_json');
      if (cached != null) return json.decode(cached) as Map<String, dynamic>;
      return null;
    }
  }

  /// GET /api/doctor/patients/:patientId/transfusions
  static Future<Map<String, dynamic>?> fetchPatientTransfusions(
    int patientId, {
    int page = 1,
    int limit = 50,
  }) async {
    final token = _getToken();
    if (token == null || token.isEmpty) return null;

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/doctor/patients/$patientId/transfusions',
    ).replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });

    ApiLogger.req('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers());
      ApiLogger.res('GET', uri, response.statusCode, response.body);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e, s) {
      ApiLogger.err('GET', uri, e, s);
      return null;
    }
  }

  /// GET /api/doctor/patients/:patientId/growth-entries
  static Future<Map<String, dynamic>?> fetchPatientGrowthEntries(
    int patientId, {
    int page = 1,
    int limit = 100,
  }) async {
    final token = _getToken();
    if (token == null || token.isEmpty) return null;

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/doctor/patients/$patientId/growth-entries',
    ).replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });

    ApiLogger.req('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers());
      ApiLogger.res('GET', uri, response.statusCode, response.body);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e, s) {
      ApiLogger.err('GET', uri, e, s);
      return null;
    }
  }

  /// GET /api/doctor/patients/:patientId/documents
  static Future<Map<String, dynamic>?> fetchPatientDocuments(
    int patientId, {
    int page = 1,
    int limit = 50,
  }) async {
    final token = _getToken();
    if (token == null || token.isEmpty) return null;

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/doctor/patients/$patientId/documents',
    ).replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });

    ApiLogger.req('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers());
      ApiLogger.res('GET', uri, response.statusCode, response.body);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e, s) {
      ApiLogger.err('GET', uri, e, s);
      return null;
    }
  }

  /// GET /api/doctor/patients/:patientId/lab-requests
  static Future<Map<String, dynamic>?> fetchPatientLabRequests(
    int patientId, {
    int page = 1,
    int limit = 50,
  }) async {
    final token = _getToken();
    if (token == null || token.isEmpty) return null;

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/doctor/patients/$patientId/lab-requests',
    ).replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });

    ApiLogger.req('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers());
      ApiLogger.res('GET', uri, response.statusCode, response.body);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e, s) {
      ApiLogger.err('GET', uri, e, s);
      return null;
    }
  }

  /// POST /api/doctor/patients/:patientId/lab-requests
  static Future<Map<String, dynamic>> createLabRequest(
    int patientId, {
    required String testName,
    String? labName,
    String? notes,
  }) async {
    final token = _getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/doctor/patients/$patientId/lab-requests',
    );

    final body = <String, dynamic>{'testName': testName};
    if (labName != null) body['labName'] = labName;
    if (notes != null) body['notes'] = notes;

    ApiLogger.req('POST', uri, body: body);
    try {
      final response = await http.post(
        uri,
        headers: _headers(),
        body: json.encode(body),
      );
      ApiLogger.res('POST', uri, response.statusCode, response.body);
      final respBody = json.decode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': respBody};
      }
      return {
        'success': false,
        'message': respBody['message'] ?? 'Failed to create request',
      };
    } catch (e, s) {
      ApiLogger.err('POST', uri, e, s);
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// POST /api/doctor/patients/:patientId/transfusions
  static Future<Map<String, dynamic>> createTransfusion(
    int patientId,
    Map<String, dynamic> body,
  ) async {
    final token = _getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    final uri = Uri.parse('${ApiConstants.baseUrl}/doctor/patients/$patientId/transfusions');
    ApiLogger.req('POST', uri, body: body);
    try {
      final response = await http.post(uri, headers: _headers(), body: json.encode(body));
      ApiLogger.res('POST', uri, response.statusCode, response.body);
      final respBody = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': respBody};
      }
      return {'success': false, 'message': respBody['message'] ?? 'Failed to create transfusion'};
    } catch (e, s) {
      ApiLogger.err('POST', uri, e, s);
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// PATCH /api/doctor/lab-requests/:id/review
  static Future<Map<String, dynamic>> reviewLabRequest(int id) async {
    final token = _getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    final uri = Uri.parse('${ApiConstants.baseUrl}/doctor/lab-requests/$id/review');
    ApiLogger.req('PATCH', uri);
    try {
      final response = await http.patch(uri, headers: _headers());
      ApiLogger.res('PATCH', uri, response.statusCode, response.body);
      final body = json.decode(response.body);
      if (response.statusCode == 200) return {'success': true, 'data': body};
      return {'success': false, 'message': body['message'] ?? 'Failed to mark reviewed'};
    } catch (e, s) {
      ApiLogger.err('PATCH', uri, e, s);
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// PATCH /api/doctor/lab-requests/:id
  static Future<Map<String, dynamic>> updateLabRequest(int id, Map<String, dynamic> body) async {
    final token = _getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    final uri = Uri.parse('${ApiConstants.baseUrl}/doctor/lab-requests/$id');
    ApiLogger.req('PATCH', uri, body: body);
    try {
      final response = await http.patch(uri, headers: _headers(), body: json.encode(body));
      ApiLogger.res('PATCH', uri, response.statusCode, response.body);
      final respBody = json.decode(response.body);
      if (response.statusCode == 200) return {'success': true, 'data': respBody};
      return {'success': false, 'message': respBody['message'] ?? 'Update failed'};
    } catch (e, s) {
      ApiLogger.err('PATCH', uri, e, s);
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// DELETE /api/doctor/lab-requests/:id
  static Future<Map<String, dynamic>> deleteLabRequest(int id) async {
    final token = _getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    final uri = Uri.parse('${ApiConstants.baseUrl}/doctor/lab-requests/$id');
    ApiLogger.req('DELETE', uri);
    try {
      final response = await http.delete(uri, headers: _headers());
      ApiLogger.res('DELETE', uri, response.statusCode, response.body);
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      }
      final body = response.body.isNotEmpty ? json.decode(response.body) : {};
      return {'success': false, 'message': body['message'] ?? 'Delete failed'};
    } catch (e, s) {
      ApiLogger.err('DELETE', uri, e, s);
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Upload a file to Supabase storage via the API. Returns publicUrl + fileName.
  /// Used as the first step before creating a Document or attaching a lab report.
  static Future<Map<String, dynamic>?> uploadFile(File file, {String bucket = 'documents'}) async {
    final token = _getToken();
    if (token == null || token.isEmpty) return null;
    final uri = Uri.parse('${ApiConstants.baseUrl}/uploads/single?bucket=$bucket');
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
      return {'fileUrl': data['publicUrl'], 'fileName': data['fileName']};
    } catch (e, s) {
      ApiLogger.err('POST', uri, e, s);
      return null;
    }
  }

  /// POST /api/doctor/patients/:patientId/documents
  static Future<Map<String, dynamic>> createDocument(
    int patientId, {
    required String fileUrl,
    String? fileName,
    String? documentType,
    String? notes,
  }) async {
    final token = _getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    final uri = Uri.parse('${ApiConstants.baseUrl}/doctor/patients/$patientId/documents');
    final body = <String, dynamic>{'fileUrl': fileUrl};
    if (fileName != null) body['fileName'] = fileName;
    if (documentType != null) body['documentType'] = documentType;
    if (notes != null) body['notes'] = notes;
    ApiLogger.req('POST', uri, body: body);
    try {
      final response = await http.post(uri, headers: _headers(), body: json.encode(body));
      ApiLogger.res('POST', uri, response.statusCode, response.body);
      final respBody = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': respBody};
      }
      return {'success': false, 'message': respBody['message'] ?? 'Failed to create document'};
    } catch (e, s) {
      ApiLogger.err('POST', uri, e, s);
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// PATCH /api/doctor/documents/:id
  static Future<Map<String, dynamic>> updateDocument(int id, Map<String, dynamic> body) async {
    final token = _getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    final uri = Uri.parse('${ApiConstants.baseUrl}/doctor/documents/$id');
    ApiLogger.req('PATCH', uri, body: body);
    try {
      final response = await http.patch(uri, headers: _headers(), body: json.encode(body));
      ApiLogger.res('PATCH', uri, response.statusCode, response.body);
      final respBody = json.decode(response.body);
      if (response.statusCode == 200) return {'success': true, 'data': respBody};
      return {'success': false, 'message': respBody['message'] ?? 'Update failed'};
    } catch (e, s) {
      ApiLogger.err('PATCH', uri, e, s);
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// DELETE /api/doctor/documents/:id
  static Future<Map<String, dynamic>> deleteDocument(int id) async {
    final token = _getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    final uri = Uri.parse('${ApiConstants.baseUrl}/doctor/documents/$id');
    ApiLogger.req('DELETE', uri);
    try {
      final response = await http.delete(uri, headers: _headers());
      ApiLogger.res('DELETE', uri, response.statusCode, response.body);
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      }
      final body = response.body.isNotEmpty ? json.decode(response.body) : {};
      return {'success': false, 'message': body['message'] ?? 'Delete failed'};
    } catch (e, s) {
      ApiLogger.err('DELETE', uri, e, s);
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// GET /api/doctor/patients/:patientId/ferritin-history
  static Future<Map<String, dynamic>?> fetchPatientFerritinHistory(
    int patientId, {
    int page = 1,
    int limit = 100,
  }) async {
    final token = _getToken();
    if (token == null || token.isEmpty) return null;
    final uri = Uri.parse('${ApiConstants.baseUrl}/doctor/patients/$patientId/ferritin-history')
        .replace(queryParameters: {'page': page.toString(), 'limit': limit.toString()});
    ApiLogger.req('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers());
      ApiLogger.res('GET', uri, response.statusCode, response.body);
      if (response.statusCode == 200) return json.decode(response.body) as Map<String, dynamic>;
      return null;
    } catch (e, s) {
      ApiLogger.err('GET', uri, e, s);
      return null;
    }
  }

  /// GET /api/doctor/patients/:patientId/chelation-history
  static Future<Map<String, dynamic>?> fetchPatientChelationHistory(
    int patientId, {
    int page = 1,
    int limit = 100,
  }) async {
    final token = _getToken();
    if (token == null || token.isEmpty) return null;
    final uri = Uri.parse('${ApiConstants.baseUrl}/doctor/patients/$patientId/chelation-history')
        .replace(queryParameters: {'page': page.toString(), 'limit': limit.toString()});
    ApiLogger.req('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers());
      ApiLogger.res('GET', uri, response.statusCode, response.body);
      if (response.statusCode == 200) return json.decode(response.body) as Map<String, dynamic>;
      return null;
    } catch (e, s) {
      ApiLogger.err('GET', uri, e, s);
      return null;
    }
  }

  /// GET /api/doctor/patients/:patientId/images
  static Future<Map<String, dynamic>?> fetchPatientImages(
    int patientId, {
    int page = 1,
    int limit = 100,
  }) async {
    final token = _getToken();
    if (token == null || token.isEmpty) return null;
    final uri = Uri.parse('${ApiConstants.baseUrl}/doctor/patients/$patientId/images')
        .replace(queryParameters: {'page': page.toString(), 'limit': limit.toString()});
    ApiLogger.req('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers());
      ApiLogger.res('GET', uri, response.statusCode, response.body);
      if (response.statusCode == 200) return json.decode(response.body) as Map<String, dynamic>;
      return null;
    } catch (e, s) {
      ApiLogger.err('GET', uri, e, s);
      return null;
    }
  }

  /// GET /api/doctor/profile
  static Future<Map<String, dynamic>?> fetchProfile() async {
    final token = _getToken();
    if (token == null || token.isEmpty) return null;

    final uri = Uri.parse('${ApiConstants.baseUrl}/doctor/profile');

    ApiLogger.req('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers());
      ApiLogger.res('GET', uri, response.statusCode, response.body);
      if (response.statusCode == 200) {
        _storage.write('doctor_profile_json', response.body);
        return json.decode(response.body) as Map<String, dynamic>;
      }
      final cached = _storage.read<String>('doctor_profile_json');
      if (cached != null) return json.decode(cached) as Map<String, dynamic>;
      return null;
    } catch (e, s) {
      ApiLogger.err('GET', uri, e, s);
      final cached = _storage.read<String>('doctor_profile_json');
      if (cached != null) return json.decode(cached) as Map<String, dynamic>;
      return null;
    }
  }

  /// PUT /api/doctor/profile
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> body,
  ) async {
    final token = _getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/doctor/profile');

    ApiLogger.req('PUT', uri, body: body);
    try {
      final response = await http.put(
        uri,
        headers: _headers(),
        body: json.encode(body),
      );
      ApiLogger.res('PUT', uri, response.statusCode, response.body);
      final respBody = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': respBody};
      }
      return {
        'success': false,
        'message': respBody['message'] ?? 'Update failed',
      };
    } catch (e, s) {
      ApiLogger.err('PUT', uri, e, s);
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
