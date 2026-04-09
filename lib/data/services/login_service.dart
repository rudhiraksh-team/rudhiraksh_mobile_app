import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';

class LoginService {
  /// Login via unified /auth/login endpoint (Supabase JWT)
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    final url = '${ApiConstants.baseUrl}/auth/login';
    debugPrint('[LoginService] POST $url');
    debugPrint('[LoginService] Body: {"email": "$email", "password": "***"}');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"email": email, "password": password}),
    );

    debugPrint('[LoginService] Status: ${response.statusCode}');
    debugPrint('[LoginService] Response body: ${response.body}');

    final data = json.decode(response.body);

    if (response.statusCode != 200) {
      final error = data['error'] ?? data['message'] ?? 'Login failed (Status ${response.statusCode})';
      debugPrint('[LoginService] Login error: $error');
      return {
        'success': false,
        'error': error,
      };
    }

    return data;
  }

  /// Fetch current user profile via /auth/me
  static Future<Map<String, dynamic>?> fetchMe(String token) async {
    final url = '${ApiConstants.baseUrl}/auth/me';
    debugPrint('[LoginService] GET $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    debugPrint('[LoginService] /auth/me status: ${response.statusCode}');
    debugPrint('[LoginService] /auth/me body: ${response.body}');

    if (response.statusCode != 200) return null;
    return json.decode(response.body);
  }

  /// Setup patient profile when user record doesn't exist yet
  /// Called when /auth/me returns "User not found"
  static Future<Map<String, dynamic>?> setupPatientProfile(
    String token, {
    required String name,
    String? phone,
    int? bloodBankId,
  }) async {
    final url = '${ApiConstants.baseUrl}/auth/setup-patient-profile';
    debugPrint('[LoginService] POST $url');

    final body = <String, dynamic>{'name': name};
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (bloodBankId != null) body['bloodBankId'] = bloodBankId;

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(body),
    );

    debugPrint('[LoginService] setup-patient-profile status: ${response.statusCode}');
    debugPrint('[LoginService] setup-patient-profile body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) return null;
    return json.decode(response.body);
  }
}
