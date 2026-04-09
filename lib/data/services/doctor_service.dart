import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';

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

    try {
      final response = await http.get(uri, headers: _headers());

      if (response.statusCode == 200) {
        _storage.write('doctor_patients_json', response.body);
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final cached = _storage.read<String>('doctor_patients_json');
        if (cached != null) return json.decode(cached) as Map<String, dynamic>;
        return null;
      }
    } catch (e) {
      debugPrint('fetchAssignedPatients error: $e');
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

    try {
      final response = await http.get(uri, headers: _headers());
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('fetchPatientTransfusions error: $e');
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

    try {
      final response = await http.get(uri, headers: _headers());
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('fetchPatientGrowthEntries error: $e');
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

    try {
      final response = await http.get(uri, headers: _headers());
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('fetchPatientDocuments error: $e');
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

    try {
      final response = await http.get(uri, headers: _headers());
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('fetchPatientLabRequests error: $e');
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

    try {
      final response = await http.post(
        uri,
        headers: _headers(),
        body: json.encode(body),
      );
      final respBody = json.decode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': respBody};
      }
      return {
        'success': false,
        'message': respBody['message'] ?? 'Failed to create request',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// GET /api/doctor/profile
  static Future<Map<String, dynamic>?> fetchProfile() async {
    final token = _getToken();
    if (token == null || token.isEmpty) return null;

    final uri = Uri.parse('${ApiConstants.baseUrl}/doctor/profile');

    try {
      final response = await http.get(uri, headers: _headers());
      if (response.statusCode == 200) {
        _storage.write('doctor_profile_json', response.body);
        return json.decode(response.body) as Map<String, dynamic>;
      }
      final cached = _storage.read<String>('doctor_profile_json');
      if (cached != null) return json.decode(cached) as Map<String, dynamic>;
      return null;
    } catch (e) {
      debugPrint('fetchDoctorProfile error: $e');
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

    try {
      final response = await http.put(
        uri,
        headers: _headers(),
        body: json.encode(body),
      );
      final respBody = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': respBody};
      }
      return {
        'success': false,
        'message': respBody['message'] ?? 'Update failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
