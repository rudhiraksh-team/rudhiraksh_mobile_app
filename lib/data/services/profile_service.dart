
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';
import 'package:rudhirakshapp/core/utils/api_logger.dart';

class ProfileService {
  static final GetStorage _storage = GetStorage();
  static const String _storageKey = 'profile_json';

  static Future<Map<String, dynamic>?> fetchProfile(String token) async {
    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    final uri = Uri.parse('${ApiConstants.baseUrl}/patients/profile');
    var request = http.Request('GET', uri);
    request.headers.addAll(headers);

    ApiLogger.req('GET', uri);
    try {
      http.StreamedResponse response = await request.send();

      final bodyString = await response.stream.bytesToString();
      ApiLogger.res('GET', uri, response.statusCode, bodyString);

      if (response.statusCode != 200) {
        // fallback to cache if available
        final cached = _storage.read<String>(_storageKey);
        if (cached != null) return json.decode(cached) as Map<String, dynamic>;
        return null;
      }

      // save to storage and return parsed map
      _storage.write(_storageKey, bodyString);
      final data = json.decode(bodyString) as Map<String, dynamic>;
      return data;
    } catch (e, s) {
      ApiLogger.err('GET', uri, e, s);
      // on exception fallback to cache
      final cached = _storage.read<String>(_storageKey);
      if (cached != null) return json.decode(cached) as Map<String, dynamic>;
      rethrow;
    }
  }

  // helper to read cached profile without calling API
  static Map<String, dynamic>? getCachedProfile() {
    final cached = _storage.read<String>(_storageKey);
    if (cached == null) return null;
    return json.decode(cached) as Map<String, dynamic>;
  }
}
