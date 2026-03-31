import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';

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
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/patient-portal/clinical-summary'),
        headers: _headers(),
      );
      if (response.statusCode != 200) return null;
      return json.decode(response.body);
    } catch (_) {
      return null;
    }
  }

  /// Fetch growth entries
  static Future<List<dynamic>> fetchGrowthEntries() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/patient-portal/growth'),
        headers: _headers(),
      );
      if (response.statusCode != 200) return [];
      final body = json.decode(response.body);
      return body['data'] ?? [];
    } catch (_) {
      return [];
    }
  }

  /// Fetch ferritin history
  static Future<List<dynamic>> fetchFerritinHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/patient-portal/ferritin'),
        headers: _headers(),
      );
      if (response.statusCode != 200) return [];
      final body = json.decode(response.body);
      return body['data'] ?? [];
    } catch (_) {
      return [];
    }
  }

  /// Fetch transfusions via patient portal
  static Future<Map<String, dynamic>?> fetchTransfusions() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/patient-portal/transfusions'),
        headers: _headers(),
      );
      if (response.statusCode != 200) return null;
      return json.decode(response.body);
    } catch (_) {
      return null;
    }
  }
}
