import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';

class LoginService {
  /// Login via unified /auth/login endpoint (Supabase JWT)
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"email": email, "password": password}),
    );

    final data = json.decode(response.body);

    if (response.statusCode != 200) {
      return {
        'success': false,
        'error': data['error'] ?? data['message'] ?? 'Login failed (Status ${response.statusCode})',
      };
    }

    return data;
  }

  /// Fetch current user profile via /auth/me
  static Future<Map<String, dynamic>?> fetchMe(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) return null;
    return json.decode(response.body);
  }
}
