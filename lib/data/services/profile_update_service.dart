import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';

class ProfileUpdateService {
  // Update patient profile via API
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> body,
  ) async {
    final box = GetStorage();
    final token = box.read('token') ?? '';
    final patientId = box.read('userId') ?? '';

    if (token.isEmpty) {
      throw Exception('No auth token found in local storage.');
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/protected/patients/$patientId',
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

      // Return success or failure with response data
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
}
