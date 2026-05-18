
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';
import 'package:rudhirakshapp/core/utils/api_logger.dart';

class BloodBankService {
  static final GetStorage _storage = GetStorage();

  static Future<Map<String, dynamic>?> fetchBloodBank(
    int id,
    String token,
  ) async {
    final storageKey = 'bloodbank_${id}_json';
    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    final uri = Uri.parse('${ApiConstants.baseUrl}/blood-banks/$id');
    var request = http.Request('GET', uri);
    request.headers.addAll(headers);

    ApiLogger.req('GET', uri);
    try {
      http.StreamedResponse response = await request.send();
      final bodyString = await response.stream.bytesToString();
      ApiLogger.res('GET', uri, response.statusCode, bodyString);

      if (response.statusCode != 200) {
        final cached = _storage.read<String>(storageKey);
        if (cached != null) return json.decode(cached) as Map<String, dynamic>;
        return null;
      }

      // save to storage and return parsed map
      _storage.write(storageKey, bodyString);
      final data = json.decode(bodyString) as Map<String, dynamic>;
      return data;
    } catch (e, s) {
      ApiLogger.err('GET', uri, e, s);
      final cached = _storage.read<String>(storageKey);
      if (cached != null) return json.decode(cached) as Map<String, dynamic>;
      rethrow;
    }
  }

  // helper to read cached bloodbank by id
  static Map<String, dynamic>? getCachedBloodBank(int id) {
    final key = 'bloodbank_${id}_json';
    final cached = _storage.read<String>(key);
    if (cached == null) return null;
    return json.decode(cached) as Map<String, dynamic>;
  }
}
