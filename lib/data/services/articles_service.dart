import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';
import 'package:rudhirakshapp/data/models/article_model.dart';

class ArticlesService {
  static final GetStorage _storage = GetStorage();

  static String? _getToken() => _storage.read<String>('token');

  static Map<String, String> _headers() {
    final token = _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  /// Fetch published articles (feed)
  static Future<List<Article>> fetchArticles({int page = 1, int limit = 20}) async {
    final token = _getToken();
    if (token == null) return [];

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/articles').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(uri, headers: _headers());
      if (response.statusCode != 200) return [];

      final body = json.decode(response.body);
      final List data = body['data'] ?? body['articles'] ?? [];
      return data.map((a) => Article.fromJson(a)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Fetch single article with comments
  static Future<Article?> fetchArticle(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/articles/$id'),
        headers: _headers(),
      );
      if (response.statusCode != 200) return null;

      final body = json.decode(response.body);
      final data = body['data'] ?? body;
      return Article.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Toggle like on an article
  static Future<bool> toggleLike(int articleId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/articles/$articleId/like'),
        headers: _headers(),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Add comment to an article
  static Future<bool> addComment(int articleId, String content, {int? parentCommentId}) async {
    try {
      final body = {'content': content};
      if (parentCommentId != null) {
        body['parentCommentId'] = parentCommentId.toString();
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/articles/$articleId/comments'),
        headers: _headers(),
        body: json.encode(body),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Delete a comment
  static Future<bool> deleteComment(int articleId, int commentId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/articles/$articleId/comments/$commentId'),
        headers: _headers(),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
