import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Centralized error reporting wrapper around Firebase Crashlytics.
///
/// All non-fatal failures the app catches itself (network errors,
/// parse errors, optional fetches that returned null) should flow through
/// here so the dev team gets a unified view in the Firebase console.
class ErrorReportingService {
  static bool _ready = false;

  /// Call once after Firebase.initializeApp() succeeds.
  static Future<void> init() async {
    try {
      // Disable in debug so dev exceptions don't pollute the dashboard.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
      _ready = true;
    } catch (e) {
      debugPrint('[ErrorReporting] init failed: $e');
    }
  }

  /// Report a handled (non-fatal) error with optional context.
  /// `tag` is a short label like "login.auth" used to group related issues.
  static Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? tag,
    String? reason,
    Map<String, Object>? context,
    bool fatal = false,
  }) async {
    debugPrint('[ErrorReporting] ${tag ?? "error"}: $error${reason != null ? " — $reason" : ""}');
    if (!_ready) return;
    try {
      if (context != null) {
        for (final entry in context.entries) {
          await FirebaseCrashlytics.instance
              .setCustomKey(entry.key, entry.value);
        }
      }
      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: reason ?? tag,
        fatal: fatal,
      );
    } catch (e) {
      debugPrint('[ErrorReporting] recordError failed: $e');
    }
  }

  /// Breadcrumb log attached to the next crash report.
  static Future<void> log(String message) async {
    debugPrint('[ErrorReporting] log: $message');
    if (!_ready) return;
    try {
      await FirebaseCrashlytics.instance.log(message);
    } catch (_) {}
  }

  /// Associate subsequent reports with the signed-in user.
  static Future<void> setUserId(String userId) async {
    if (!_ready) return;
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    } catch (_) {}
  }
}
