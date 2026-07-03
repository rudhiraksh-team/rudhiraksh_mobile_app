import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';
import 'package:rudhirakshapp/core/utils/api_logger.dart';
import 'package:rudhirakshapp/data/models/chat_models.dart';

/// Talks to the role-aware /api/chatbot endpoints. Replies are grounded in
/// real data server-side based on the caller's role, so this layer just
/// relays messages and persists nothing beyond the conversation id (handled
/// by the controller).
class ChatbotService {
  static final GetStorage _storage = GetStorage();

  static Map<String, String> _headers() {
    final token = _storage.read<String>('token');
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  /// Create an empty conversation; returns its id or null on failure.
  static Future<int?> createConversation() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/chatbot/conversations');
    ApiLogger.req('POST', uri);
    try {
      final response = await http.post(uri, headers: _headers(), body: json.encode({}));
      ApiLogger.res('POST', uri, response.statusCode, response.body);
      if (response.statusCode != 200 && response.statusCode != 201) return null;
      final body = json.decode(response.body);
      final data = body['data'] ?? body;
      return (data['id'] as num?)?.toInt();
    } catch (e, s) {
      ApiLogger.err('POST', uri, e, s);
      return null;
    }
  }

  /// Send a message and return the assistant's reply.
  static Future<ChatReply?> sendMessage(int conversationId, String message) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/chatbot/conversations/$conversationId/messages');
    ApiLogger.req('POST', uri, body: message);
    try {
      final response = await http.post(
        uri,
        headers: _headers(),
        body: json.encode({'message': message}),
      );
      ApiLogger.res('POST', uri, response.statusCode, response.body);
      if (response.statusCode != 200) return null;
      final body = json.decode(response.body);
      final data = body['data'] ?? body;
      return ChatReply.fromJson(Map<String, dynamic>.from(data));
    } catch (e, s) {
      ApiLogger.err('POST', uri, e, s);
      return null;
    }
  }

  /// Fetch a conversation's messages (used to restore a persisted thread).
  static Future<List<ChatMessage>> fetchMessages(int conversationId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/chatbot/conversations/$conversationId');
    ApiLogger.req('GET', uri);
    try {
      final response = await http.get(uri, headers: _headers());
      ApiLogger.res('GET', uri, response.statusCode, response.body);
      if (response.statusCode != 200) return [];
      final body = json.decode(response.body);
      final data = body['data'] ?? body;
      final msgs = (data['messages'] as List?) ?? [];
      return msgs
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e, s) {
      ApiLogger.err('GET', uri, e, s);
      return [];
    }
  }
}
