import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';
import 'package:rudhirakshapp/data/models/transfusion_list_model.dart';

class TransfusionListService {
  // Storage instance for caching and token
  final GetStorage storage = GetStorage();

  // Retrieve auth token from storage
  String? _getToken() {
    final token = storage.read<String>('token');
    return token;
  }

  // Fetch transfusion list from API with caching
  Future<TransfusionResponse?> fetchTransfusions({
    int? patientId,
    int? bloodbankId,
    int limit = 50,
    int offset = 0,
  }) async {
    final token = _getToken();
    if (token == null || token.isEmpty) return null;

    final uri = Uri.parse('${ApiConstants.baseUrl}/patient-portal/transfusions').replace(
      queryParameters: {
        'limit': limit.toString(),
        'page': '1',
      },
    );

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      final request = http.Request('GET', uri);
      request.headers.addAll(headers);

      final streamedResponse = await request.send();
      final bodyString = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(bodyString);
        final parsed = TransfusionResponse.fromJson(decoded);
        // Save normalized format so DashboardController can read it consistently
        storage.write('transfusions_json', json.encode(parsed.toJson()));
        return parsed;
      } else {
        // Load cached data if API fails
        final cached = storage.read<String>('transfusions_json');
        if (cached != null) {
          final Map<String, dynamic> decoded = json.decode(cached);
          return TransfusionResponse.fromJson(decoded);
        }
        return null;
      }
    } catch (_) {
      // Load cached data on exception
      final cached = storage.read<String>('transfusions_json');
      if (cached != null) {
        final Map<String, dynamic> decoded = json.decode(cached);
        return TransfusionResponse.fromJson(decoded);
      }
      rethrow;
    }
  }
}
