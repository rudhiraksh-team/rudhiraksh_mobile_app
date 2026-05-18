import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/data/services/error_reporting_service.dart';

class AppUpdateService {
  static DateTime? _lastCheckedAt;
  static bool _checkInFlight = false;
  static bool _flexibleDownloadStarted = false;

  // Avoid hammering the Play update API on every resume. The user toggling
  // between apps shouldn't trigger a network call each time.
  static const _minCheckInterval = Duration(minutes: 30);

  // Play Console "in-app update priority" threshold above which we treat the
  // release as mandatory and use the immediate (blocking) flow. Set priority
  // 4 or 5 in Play Console for breaking releases.
  static const _forceUpdatePriorityThreshold = 4;

  /// Public entry point. Fire-and-forget; never throws. No-op outside Android
  /// and outside Play-installed builds (the plugin handles that internally).
  static Future<void> checkForUpdate() async {
    if (_checkInFlight) return;
    final now = DateTime.now();
    if (_lastCheckedAt != null &&
        now.difference(_lastCheckedAt!) < _minCheckInterval) {
      return;
    }
    _checkInFlight = true;
    _lastCheckedAt = now;

    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return;
      }

      final isHighPriority =
          (info.updatePriority) >= _forceUpdatePriorityThreshold;

      if (isHighPriority && info.immediateUpdateAllowed) {
        // Blocking, full-screen Google Play update UI. The user cannot
        // dismiss this without updating (or force-killing the app).
        await InAppUpdate.performImmediateUpdate();
        return;
      }

      if (info.flexibleUpdateAllowed && !_flexibleDownloadStarted) {
        _flexibleDownloadStarted = true;
        // Downloads in the background; the user keeps using the app.
        // When the download finishes we prompt them to apply it.
        final result = await InAppUpdate.startFlexibleUpdate();
        if (result == AppUpdateResult.success) {
          await _promptCompleteFlexibleUpdate();
        }
      }
    } catch (e, s) {
      // Plugin throws on non-Play installs (debug, sideload, emulator).
      // This is expected, not actionable — just log.
      if (kDebugMode) {
        debugPrint('AppUpdateService.checkForUpdate skipped: $e');
      }
      ErrorReportingService.recordError(e, s, tag: 'app_update.check');
    } finally {
      _checkInFlight = false;
    }
  }

  static Future<void> _promptCompleteFlexibleUpdate() async {
    Get.snackbar(
      'Update ready',
      'Restart to apply the latest version.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 8),
      mainButton: TextButton(
        onPressed: () async {
          try {
            await InAppUpdate.completeFlexibleUpdate();
          } catch (e, s) {
            ErrorReportingService.recordError(e, s, tag: 'app_update.complete');
          }
        },
        child: const Text(
          'RESTART',
          style: TextStyle(
            color: AppColors.brandRed,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
