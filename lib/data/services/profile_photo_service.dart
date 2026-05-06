import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';
import 'package:rudhirakshapp/data/services/error_reporting_service.dart';

class ProfilePhotoResult {
  final bool success;
  final String? url;
  final String? errorMessage;

  const ProfilePhotoResult._({
    required this.success,
    this.url,
    this.errorMessage,
  });

  factory ProfilePhotoResult.ok(String url) =>
      ProfilePhotoResult._(success: true, url: url);
  factory ProfilePhotoResult.fail(String message) =>
      ProfilePhotoResult._(success: false, errorMessage: message);
}

/// Two-step upload that mirrors how the backend wants it:
///   1. POST /api/uploads/single?bucket=profile-images  → returns publicUrl
///   2. PUT  /api/patients/profile                      → persist profileImageUrl
///
/// Doing both here keeps the controller simple — caller gets a single result
/// and only has to refresh local profile state on success.
class ProfilePhotoService {
  static const _uploadTimeout = Duration(seconds: 60);
  static const _persistTimeout = Duration(seconds: 20);
  // Backend bucket cap is 10MB; we cap a bit lower to leave headroom and
  // because profile pics rarely need more than this.
  static const _maxBytes = 5 * 1024 * 1024;

  static Future<ProfilePhotoResult> uploadAndPersist(File file) async {
    final box = GetStorage();
    final token = box.read<String>('token');
    if (token == null || token.isEmpty) {
      return ProfilePhotoResult.fail('Not signed in');
    }

    final size = await file.length();
    if (size > _maxBytes) {
      return ProfilePhotoResult.fail('Image too large. Max 5 MB.');
    }

    // ---- Step 1: upload to storage bucket ----
    final String publicUrl;
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/uploads/single?bucket=profile-images',
      );
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await request.send().timeout(_uploadTimeout);
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode != 200 && streamed.statusCode != 201) {
        await ErrorReportingService.recordError(
          StateError('uploads/single failed'),
          StackTrace.current,
          tag: 'profile_photo.upload',
          context: {
            'status': streamed.statusCode,
            'body_preview': _preview(body),
          },
        );
        return ProfilePhotoResult.fail(
          'Photo upload failed (${streamed.statusCode})',
        );
      }

      final decoded = _safeDecode(body);
      // sendSuccess wraps the payload as { success, message, data: {...} }.
      String? url;
      if (decoded is Map<String, dynamic>) {
        final dataField = decoded['data'];
        if (dataField is Map && dataField['publicUrl'] is String) {
          url = dataField['publicUrl'] as String;
        } else if (decoded['publicUrl'] is String) {
          url = decoded['publicUrl'] as String;
        }
      }
      if (url == null || url.isEmpty) {
        await ErrorReportingService.recordError(
          StateError('uploads/single missing publicUrl'),
          StackTrace.current,
          tag: 'profile_photo.upload.shape',
          context: {'body_preview': _preview(body)},
        );
        return ProfilePhotoResult.fail('Upload succeeded but no URL returned');
      }
      publicUrl = url;
    } on TimeoutException {
      return ProfilePhotoResult.fail(
        'Upload timed out. Try a smaller image or better connection.',
      );
    } on SocketException {
      return ProfilePhotoResult.fail('No internet connection');
    } catch (e, s) {
      await ErrorReportingService.recordError(e, s, tag: 'profile_photo.upload');
      return ProfilePhotoResult.fail('Upload failed. Please try again.');
    }

    // ---- Step 2: persist URL on patient profile ----
    try {
      final resp = await http
          .put(
            Uri.parse('${ApiConstants.baseUrl}/patients/profile'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode({'profileImageUrl': publicUrl}),
          )
          .timeout(_persistTimeout);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return ProfilePhotoResult.ok(publicUrl);
      }

      await ErrorReportingService.recordError(
        StateError('patients/profile PUT failed'),
        StackTrace.current,
        tag: 'profile_photo.persist',
        context: {
          'status': resp.statusCode,
          'body_preview': _preview(resp.body),
        },
      );
      return ProfilePhotoResult.fail(
        'Photo uploaded but profile not updated (${resp.statusCode})',
      );
    } on TimeoutException {
      return ProfilePhotoResult.fail(
        'Profile update timed out. Photo uploaded — try refreshing.',
      );
    } on SocketException {
      return ProfilePhotoResult.fail('No internet connection');
    } catch (e, s) {
      await ErrorReportingService.recordError(e, s, tag: 'profile_photo.persist');
      return ProfilePhotoResult.fail('Could not save profile photo.');
    }
  }

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
}
