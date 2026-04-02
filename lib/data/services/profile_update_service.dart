import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';

class ProfileUpdateService {
  /// Update patient profile via PUT /api/patients/profile
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> body,
  ) async {
    final box = GetStorage();
    final token = box.read('token') ?? '';

    if (token.isEmpty) {
      throw Exception('No auth token found in local storage.');
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/patients/profile',
    );

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final resp = await http.put(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      final respBody = resp.body.isNotEmpty ? json.decode(resp.body) : {};

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return {
          'success': true,
          'statusCode': resp.statusCode,
          'data': respBody,
        };
      } else {
        return {
          'success': false,
          'statusCode': resp.statusCode,
          'message':
              respBody['message'] ?? resp.reasonPhrase ?? 'Unknown error',
          'data': respBody,
        };
      }
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  /// Update FCM token for any user role via PUT /api/users/:id
  static Future<Map<String, dynamic>> updateFcmToken(String fcmToken) async {
    final box = GetStorage();
    final token = box.read('token') ?? '';
    final meData = box.read('supabaseUserId');

    if (token.isEmpty) {
      throw Exception('No auth token found in local storage.');
    }

    // For patients, use the patient profile endpoint
    final userRole = box.read('userRole') ?? 'patient';
    final Uri uri;
    if (userRole == 'patient') {
      uri = Uri.parse('${ApiConstants.baseUrl}/patients/profile');
    } else {
      // For doctors/staff, use the users endpoint
      final userId = box.read('dbUserId');
      if (userId == null) {
        throw Exception('No user ID found in local storage.');
      }
      uri = Uri.parse('${ApiConstants.baseUrl}/users/$userId');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final resp = await http.put(
        uri,
        headers: headers,
        body: json.encode({'fcmToken': fcmToken}),
      );

      final respBody = resp.body.isNotEmpty ? json.decode(resp.body) : {};

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return {'success': true, 'data': respBody};
      } else {
        return {
          'success': false,
          'statusCode': resp.statusCode,
          'message':
              respBody['message'] ?? resp.reasonPhrase ?? 'Unknown error',
        };
      }
    } catch (e) {
      throw Exception('FCM token update failed: $e');
    }
  }
}
