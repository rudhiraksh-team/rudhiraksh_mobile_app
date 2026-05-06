import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  // Single-call timeout; retry-once doubles the worst-case wait if needed.
  static const _fcmTimeout = Duration(seconds: 15);

  /// Update FCM token. Single-shot timeout, one retry on transient failures
  /// (timeout / 5xx / connection drop). Returns a structured result; never
  /// throws on network conditions so callers can treat it as best-effort.
  static Future<Map<String, dynamic>> updateFcmToken(String fcmToken) async {
    final box = GetStorage();
    final token = box.read('token') ?? '';

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
    final body = json.encode({'fcmToken': fcmToken});

    final first = await _putFcmToken(uri, headers, body);
    if (first['success'] == true) return first;

    final retryable = first['transient'] == true;
    if (!retryable) return first;

    await Future.delayed(const Duration(seconds: 1));
    return _putFcmToken(uri, headers, body);
  }

  static Future<Map<String, dynamic>> _putFcmToken(
    Uri uri,
    Map<String, String> headers,
    String body,
  ) async {
    try {
      final resp = await http.put(uri, headers: headers, body: body)
          .timeout(_fcmTimeout);

      final respBody = resp.body.isNotEmpty
          ? (jsonDecodeOrNull(resp.body) ?? <String, dynamic>{})
          : <String, dynamic>{};

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return {'success': true, 'data': respBody};
      }
      return {
        'success': false,
        'statusCode': resp.statusCode,
        'message':
            (respBody is Map ? respBody['message'] : null) ?? resp.reasonPhrase ?? 'Unknown error',
        'transient': resp.statusCode >= 500,
      };
    } on TimeoutException {
      return {'success': false, 'message': 'timeout', 'transient': true};
    } on SocketException {
      return {'success': false, 'message': 'no_internet', 'transient': false};
    } on http.ClientException {
      return {'success': false, 'message': 'connection_lost', 'transient': true};
    } catch (e) {
      return {'success': false, 'message': e.toString(), 'transient': false};
    }
  }

  static dynamic jsonDecodeOrNull(String body) {
    try {
      return json.decode(body);
    } on FormatException {
      return null;
    }
  }
}
