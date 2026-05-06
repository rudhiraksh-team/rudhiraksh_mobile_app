import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';
import 'package:rudhirakshapp/data/services/error_reporting_service.dart';

/// Stable error codes the UI uses to pick a user-facing message.
class LoginErrorCodes {
  static const noInternet = 'no_internet';
  static const timeout = 'timeout';
  static const invalidCredentials = 'invalid_credentials';
  static const serverError = 'server_error';
  static const badResponse = 'bad_response';
  static const unknown = 'unknown';
}

/// Uniform result envelope so callers never have to inspect `response.statusCode`
/// or worry about thrown exceptions.
class LoginResult {
  final bool success;
  final Map<String, dynamic>? data;
  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;

  const LoginResult._({
    required this.success,
    this.data,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  factory LoginResult.ok(Map<String, dynamic> data) =>
      LoginResult._(success: true, data: data);

  factory LoginResult.fail(String code, String message, {int? statusCode}) =>
      LoginResult._(
        success: false,
        errorCode: code,
        errorMessage: message,
        statusCode: statusCode,
      );
}

class LoginService {
  // Auth-blocking calls get a generous budget — slow networks may need it.
  static const _authTimeout = Duration(seconds: 20);
  // Non-auth follow-ups should fail faster; the user is already authenticated.
  static const _meTimeout = Duration(seconds: 15);

  /// Login via /auth/login. Retries once on transient failure.
  static Future<LoginResult> login(String email, String password) async {
    return _runWithRetry(
      tag: 'login.auth',
      attempt: () => _doLogin(email, password),
    );
  }

  static Future<LoginResult> _doLogin(String email, String password) async {
    final url = '${ApiConstants.baseUrl}/auth/login';
    debugPrint('[LoginService] POST $url');

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(_authTimeout);

      debugPrint('[LoginService] Status: ${response.statusCode}');

      final body = _safeDecode(response.body);
      if (body is! Map<String, dynamic>) {
        await ErrorReportingService.recordError(
          FormatException('Non-JSON or non-object login response'),
          StackTrace.current,
          tag: 'login.auth',
          context: {
            'status': response.statusCode,
            'body_preview': _preview(response.body),
          },
        );
        return LoginResult.fail(
          LoginErrorCodes.badResponse,
          'Unexpected response from server',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode == 200) {
        return LoginResult.ok(body);
      }

      final serverMsg = (body['error'] ?? body['message'])?.toString();
      if (response.statusCode == 401 || response.statusCode == 403) {
        return LoginResult.fail(
          LoginErrorCodes.invalidCredentials,
          serverMsg ?? 'Invalid email or password',
          statusCode: response.statusCode,
        );
      }
      if (response.statusCode >= 500) {
        return LoginResult.fail(
          LoginErrorCodes.serverError,
          serverMsg ?? 'Server error. Please try again shortly.',
          statusCode: response.statusCode,
        );
      }
      return LoginResult.fail(
        LoginErrorCodes.unknown,
        serverMsg ?? 'Login failed (${response.statusCode})',
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      return LoginResult.fail(
        LoginErrorCodes.timeout,
        'Connection timed out. Please check your network and try again.',
      );
    } on SocketException {
      return LoginResult.fail(
        LoginErrorCodes.noInternet,
        'No internet connection',
      );
    } on HandshakeException catch (e, s) {
      await ErrorReportingService.recordError(e, s, tag: 'login.auth.tls');
      return LoginResult.fail(
        LoginErrorCodes.noInternet,
        'Secure connection failed. Check your network.',
      );
    } on http.ClientException catch (e, s) {
      // ClientException covers connection drops mid-request.
      await ErrorReportingService.recordError(e, s, tag: 'login.auth.client');
      return LoginResult.fail(
        LoginErrorCodes.timeout,
        'Network connection lost. Please try again.',
      );
    } catch (e, s) {
      await ErrorReportingService.recordError(e, s, tag: 'login.auth');
      return LoginResult.fail(
        LoginErrorCodes.unknown,
        'Something went wrong. Please try again.',
      );
    }
  }

  /// Fetch current user via /auth/me. Retries once on transient failure.
  static Future<LoginResult> fetchMe(String token) async {
    return _runWithRetry(
      tag: 'login.me',
      attempt: () => _doFetchMe(token),
    );
  }

  static Future<LoginResult> _doFetchMe(String token) async {
    final url = '${ApiConstants.baseUrl}/auth/me';
    debugPrint('[LoginService] GET $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(_meTimeout);

      debugPrint('[LoginService] /auth/me status: ${response.statusCode}');

      if (response.statusCode == 404) {
        // Caller will trigger setup-patient-profile.
        return LoginResult.fail(
          LoginErrorCodes.unknown,
          'User profile not found',
          statusCode: 404,
        );
      }

      final body = _safeDecode(response.body);
      if (body is! Map<String, dynamic>) {
        return LoginResult.fail(
          LoginErrorCodes.badResponse,
          'Unexpected response from server',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode == 200) {
        return LoginResult.ok(body);
      }
      if (response.statusCode >= 500) {
        return LoginResult.fail(
          LoginErrorCodes.serverError,
          'Server error',
          statusCode: response.statusCode,
        );
      }
      return LoginResult.fail(
        LoginErrorCodes.unknown,
        body['error']?.toString() ?? 'Failed to load profile',
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      return LoginResult.fail(
        LoginErrorCodes.timeout,
        'Connection timed out',
      );
    } on SocketException {
      return LoginResult.fail(
        LoginErrorCodes.noInternet,
        'No internet connection',
      );
    } on http.ClientException catch (e, s) {
      await ErrorReportingService.recordError(e, s, tag: 'login.me.client');
      return LoginResult.fail(
        LoginErrorCodes.timeout,
        'Network connection lost',
      );
    } catch (e, s) {
      await ErrorReportingService.recordError(e, s, tag: 'login.me');
      return LoginResult.fail(
        LoginErrorCodes.unknown,
        'Failed to load profile',
      );
    }
  }

  /// Setup patient profile when /auth/me returns 404.
  static Future<LoginResult> setupPatientProfile(
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

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(_authTimeout);

      debugPrint('[LoginService] setup-patient-profile status: ${response.statusCode}');

      final decoded = _safeDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return LoginResult.fail(
          LoginErrorCodes.badResponse,
          'Unexpected response from server',
          statusCode: response.statusCode,
        );
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResult.ok(decoded);
      }
      return LoginResult.fail(
        LoginErrorCodes.unknown,
        decoded['error']?.toString() ?? 'Profile setup failed',
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      return LoginResult.fail(LoginErrorCodes.timeout, 'Connection timed out');
    } on SocketException {
      return LoginResult.fail(LoginErrorCodes.noInternet, 'No internet connection');
    } catch (e, s) {
      await ErrorReportingService.recordError(e, s, tag: 'login.setup');
      return LoginResult.fail(LoginErrorCodes.unknown, 'Profile setup failed');
    }
  }

  // -------- helpers --------

  static dynamic _safeDecode(String body) {
    if (body.isEmpty) return null;
    try {
      return json.decode(body);
    } on FormatException {
      return null;
    }
  }

  static String _preview(String body) {
    if (body.length <= 200) return body;
    return '${body.substring(0, 200)}…';
  }

  /// Retries an attempt once on transient codes (timeout / server_error).
  /// Auth/credential failures and bad responses are NOT retried.
  static Future<LoginResult> _runWithRetry({
    required String tag,
    required Future<LoginResult> Function() attempt,
  }) async {
    final first = await attempt();
    if (first.success) return first;
    final retryable = first.errorCode == LoginErrorCodes.timeout ||
        first.errorCode == LoginErrorCodes.serverError;
    if (!retryable) return first;

    debugPrint('[LoginService] $tag: retrying after ${first.errorCode}');
    await Future.delayed(const Duration(milliseconds: 800));
    final second = await attempt();
    if (!second.success) {
      await ErrorReportingService.log(
        '$tag retry exhausted: first=${first.errorCode}, second=${second.errorCode}',
      );
    }
    return second;
  }
}
