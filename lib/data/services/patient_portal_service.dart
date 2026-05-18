import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';
import 'package:rudhirakshapp/core/utils/api_logger.dart';

class PatientPortalService {
  static final GetStorage _storage = GetStorage();

  static Map<String, String> _headers() {
    final token = _storage.read<String>('token');
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  /// Fetch clinical summary for the patient
  static Future<Map<String, dynamic>?> fetchClinicalSummary() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/patient-portal/clinical-summary');
    ApiLogger.req('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers());
      ApiLogger.res('GET', uri, response.statusCode, response.body);
      if (response.statusCode != 200) return null;
      return json.decode(response.body);
    } catch (e, s) {
      ApiLogger.err('GET', uri, e, s);
      return null;
    }
  }

  /// Fetch growth entries
  static Future<List<dynamic>> fetchGrowthEntries() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/patient-portal/growth');
    ApiLogger.req('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers());
      ApiLogger.res('GET', uri, response.statusCode, response.body);
      if (response.statusCode != 200) return [];
      final body = json.decode(response.body);
      return body['data'] ?? [];
    } catch (e, s) {
      ApiLogger.err('GET', uri, e, s);
      return [];
    }
  }

  /// Fetch ferritin history
  static Future<List<dynamic>> fetchFerritinHistory() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/patient-portal/ferritin');
    ApiLogger.req('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers());
      ApiLogger.res('GET', uri, response.statusCode, response.body);
      if (response.statusCode != 200) return [];
      final body = json.decode(response.body);
      return body['data'] ?? [];
    } catch (e, s) {
      ApiLogger.err('GET', uri, e, s);
      return [];
    }
  }

  /// Fetch transfusions via patient portal
  static Future<Map<String, dynamic>?> fetchTransfusions() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/patient-portal/transfusions');
    ApiLogger.req('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers());
      ApiLogger.res('GET', uri, response.statusCode, response.body);
      if (response.statusCode != 200) return null;
      return json.decode(response.body);
    } catch (e, s) {
      ApiLogger.err('GET', uri, e, s);
      return null;
    }
  }
}
