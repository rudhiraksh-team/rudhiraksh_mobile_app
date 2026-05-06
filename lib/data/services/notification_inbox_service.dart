import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rudhirakshapp/core/utils/api_constant.dart';
import 'package:rudhirakshapp/data/models/notification_model.dart';

/// Talks to the server-side notification inbox at `/api/notifications/me`.
///
/// The inbox is the source of truth for *every* notification ever sent to
/// this user (transfusion reminders, lab requests, admin broadcasts, etc).
/// FCM is only the live push channel — when the user has notifications
/// disabled, opens the app from cold, or simply re-installs, the FCM
/// stream alone misses everything.
///
/// Calling [fetchInbox] on the notifications screen merges the server
/// list with anything we already cached locally from FCM, deduped by
/// the inbox row id (prefix `srv_`) so cards never appear twice.
class NotificationInboxService {
  static final GetStorage _storage = GetStorage();

  static String? _getToken() => _storage.read<String>('token');

  /// Returns the server inbox as a list of [NotificationItem]. Network
  /// failures return an empty list — the UI keeps any local cache it has.
  static Future<List<NotificationItem>> fetchInbox({int limit = 50}) async {
    final token = _getToken();
    if (token == null || token.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/notifications/me?limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        debugPrint('[notif-inbox] GET failed ${response.statusCode}: ${response.body}');
        return [];
      }
      final body = json.decode(response.body) as Map<String, dynamic>;
      final raw = (body['data'] as List?) ?? const [];
      return raw
          .whereType<Map>()
          .map((m) => _itemFromInboxRow(Map<String, dynamic>.from(m)))
          .toList();
    } catch (e) {
      debugPrint('[notif-inbox] fetch error: $e');
      return [];
    }
  }

  /// Mark a single inbox row read. Server id of the inbox row, NOT the
  /// FCM message id — pass the integer suffix off `srv_<id>`.
  static Future<bool> markRead(int inboxRowId) async {
    final token = _getToken();
    if (token == null || token.isEmpty) return false;

    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/notifications/me/$inboxRowId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[notif-inbox] markRead error: $e');
      return false;
    }
  }

  /// Mark all inbox rows read in a single round-trip.
  static Future<bool> markAllRead() async {
    final token = _getToken();
    if (token == null || token.isEmpty) return false;

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/notifications/me/read-all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[notif-inbox] markAllRead error: $e');
      return false;
    }
  }

  static NotificationItem _itemFromInboxRow(Map<String, dynamic> row) {
    final id = row['id'];
    DateTime? createdAt;
    final raw = row['createdAt'];
    if (raw is String) createdAt = DateTime.tryParse(raw);
    final dateStr = createdAt != null
        ? DateFormat('MMM d, yyyy').format(createdAt.toLocal())
        : DateFormat('MMM d, yyyy').format(DateTime.now());

    return NotificationItem(
      id: 'srv_$id',
      title: (row['title'] ?? '').toString(),
      message: (row['body'] ?? '').toString(),
      date: dateStr,
      isRead: row['isRead'] == true,
    );
  }

  /// Extracts the integer server-row id from a `srv_<n>` notification id.
  /// Returns null for FCM-only items (which use UUID-style ids).
  static int? serverIdFor(String id) {
    if (!id.startsWith('srv_')) return null;
    return int.tryParse(id.substring(4));
  }
}
