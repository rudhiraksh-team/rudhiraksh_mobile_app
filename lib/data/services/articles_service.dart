import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rudhirakshapp/core/utils/api_constant.dart';
import 'package:rudhirakshapp/data/models/article_model.dart';
import 'package:rudhirakshapp/data/services/error_reporting_service.dart';

// Distinct tag so you can grep / filter logcat for "ARTICLES" and see only
// this flow. Uses dart:developer.log so the lines also show up nicely in the
// IDE's "Run" / "Logcat" panes, not just `flutter run`.
void _log(String message) {
  developer.log(message, name: 'ARTICLES');
  // Also use print so it lands in plain `flutter run` and `adb logcat` output.
  // ignore: avoid_print
  print('[ARTICLES] $message');
}

/// Result of a feed fetch. Either `articles` is populated (possibly empty,
/// which is a legitimate state) or `error` carries a human-readable reason.
class ArticlesFetchResult {
  final List<Article> articles;
  final String? error;
  const ArticlesFetchResult({this.articles = const [], this.error});
}

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

  /// Fetch published articles (feed). Returns a result object so the caller
  /// can distinguish a legitimate empty list from a network/auth failure.
  static Future<ArticlesFetchResult> fetchArticles({
    int page = 1,
    int limit = 20,
  }) async {
    final token = _getToken();
    if (token == null) {
      _log('NO TOKEN in storage — user is not signed in.');
      return const ArticlesFetchResult(
        error: 'You are not signed in. Please log in again.',
      );
    }
    _log('token length=${token.length} (first 12=${token.substring(0, token.length < 12 ? token.length : 12)}…)');

    final uri = Uri.parse('${ApiConstants.baseUrl}/articles').replace(
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    _log('GET $uri');

    try {
      final response = await http.get(uri, headers: _headers());
      _log('status=${response.statusCode} bytes=${response.bodyBytes.length}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List data = body['data'] ?? body['articles'] ?? [];
        _log('OK — parsed ${data.length} article(s)');
        return ArticlesFetchResult(
          articles: data.map((a) => Article.fromJson(a)).toList(),
        );
      }

      // Print the raw body (truncated) so we can see the exact server response.
      final preview = response.body.length > 400
          ? '${response.body.substring(0, 400)}…'
          : response.body;
      _log('FAILED body=$preview');

      final message = _extractMessage(response.body) ??
          'Server returned ${response.statusCode}';
      ErrorReportingService.recordError(
        'articles.list ${response.statusCode}: $message',
        StackTrace.current,
        tag: 'articles.list',
        context: {'status': response.statusCode},
      );
      return ArticlesFetchResult(error: message);
    } on SocketException catch (e, s) {
      _log('SocketException: $e');
      ErrorReportingService.recordError(e, s, tag: 'articles.list.network');
      return const ArticlesFetchResult(
        error: 'Could not reach the server. Check your connection.',
      );
    } catch (e, s) {
      _log('Exception: $e');
      ErrorReportingService.recordError(e, s, tag: 'articles.list');
      return ArticlesFetchResult(error: 'Unexpected error: $e');
    }
  }

  /// Fetch single article with comments
  static Future<Article?> fetchArticle(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/articles/$id'),
        headers: _headers(),
      );
      if (response.statusCode != 200) {
        ErrorReportingService.recordError(
          'articles.get ${response.statusCode}',
          StackTrace.current,
          tag: 'articles.get',
          context: {'id': id, 'status': response.statusCode},
        );
        return null;
      }

      final body = json.decode(response.body);
      final data = body['data'] ?? body;
      return Article.fromJson(data);
    } catch (e, s) {
      ErrorReportingService.recordError(e, s, tag: 'articles.get');
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
    } catch (e, s) {
      ErrorReportingService.recordError(e, s, tag: 'articles.like');
      return false;
    }
  }

  /// Add comment to an article
  static Future<bool> addComment(
    int articleId,
    String content, {
    int? parentCommentId,
  }) async {
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
    } catch (e, s) {
      ErrorReportingService.recordError(e, s, tag: 'articles.addComment');
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
    } catch (e, s) {
      ErrorReportingService.recordError(e, s, tag: 'articles.deleteComment');
      return false;
    }
  }

  /// Pull a useful one-line message from an API error body. Falls back to
  /// null when the body isn't JSON or doesn't carry a message field.
  static String? _extractMessage(String body) {
    if (body.isEmpty) return null;
    try {
      final decoded = json.decode(body);
      if (decoded is Map) {
        final msg = decoded['message'] ?? decoded['error'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
    } catch (_) {}
    return null;
  }
}
