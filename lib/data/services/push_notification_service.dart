// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:rudhirakshapp/controllers/notification_controller.dart';
import 'package:rudhirakshapp/data/models/notification_model.dart';
import 'package:rudhirakshapp/data/storage/notification_storage.dart';
import 'package:rudhirakshapp/data/services/error_reporting_service.dart';
import 'package:rudhirakshapp/data/services/profile_update_service.dart';
import 'package:rudhirakshapp/routes/app_routes.dart';

class PushNotificationService {
  // Firebase Messaging instance
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  // Local notifications plugin instance
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Guards to avoid double initialization / duplicate listeners
  static bool _initialized = false;
  static bool _handlersRegistered = false;
  static bool _permissionRequestInProgress = false;

  // Core init: no permission prompt here
  static Future<void> initializeCore() async {
    if (_initialized) return;
    _initialized = true;

    await Firebase.initializeApp();
    await _fcm.setAutoInitEnabled(true); // ensure auto-init

    // Local notifications initialization. The drawable name MUST exist in
     // android/app/src/main/res/mipmap-* — we use ic_launcher because that's
    // the only icon present in this project. Pointing at a missing resource
    // makes flutter_local_notifications.show() silently fail.
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: DarwinInitializationSettings(),
    );
    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    // Explicitly create the high-importance channel so background FCM pushes
    // (which Android dispatches without going through this plugin) can find it.
    // Channel id MUST match the AndroidManifest meta-data
    // `default_notification_channel_id` and the value used in _showNotification.
    final androidImpl = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'Used for lab requests, transfusion reminders, etc.',
          importance: Importance.max,
        ),
      );
    }

    // Token retrieval (silent)
    try {
      final token = await _fcm.getToken();

      if (token != null && token.isNotEmpty) {
        final box = GetStorage();
        box.write('fcmToken', token);
        // Optionally send to backend now (or wait until user accepts)
        await _sendTokenToBackend(token);
        if (kDebugMode) print('Silent initial FCM token: $token');
      } else {
        if (kDebugMode) print('Initial FCM token null — waiting for refresh.');
      }
    } catch (e) {
      if (kDebugMode) print('Error getting initial token: $e');
    }

    // Listen for token refresh once
    _fcm.onTokenRefresh.listen((newToken) async {
      final box = GetStorage();
      final old = box.read<String>('fcmToken');
      if (old != newToken) {
        box.write('fcmToken', newToken);
        await _sendTokenToBackend(newToken);
        if (kDebugMode) print('FCM token refreshed: $newToken');
      }
    });

    // Register all message handlers (only once)
    _setupMessageHandlers();
  }

  // Register message handlers (foreground, background tap, terminated tap)
  static void _setupMessageHandlers() {
    if (_handlersRegistered) return;
    _handlersRegistered = true;

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      try {
        _showNotification(message);
        _saveNotification(message);
      } catch (e) {
        if (kDebugMode) print('Error handling onMessage: $e');
      }
      if (kDebugMode) print('onMessage: ${message.data}');
    });

    // When app opened from background (user taps notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      try {
        _handleNotificationClick(message);
      } catch (e) {
        if (kDebugMode) print('Error handling onMessageOpenedApp: $e');
      }
      if (kDebugMode) print('onMessageOpenedApp: ${message.data}');
    });

    // When app was terminated and launched from notification
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        try {
          _handleNotificationClick(message);
        } catch (e) {
          if (kDebugMode) print('Error handling getInitialMessage: $e');
        }
      }
    });
  }

  static void _handleNotificationClick(RemoteMessage message) {
    // Save + mark read (same as before)
    _saveNotification(message);

    final id =
        message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    if (Get.isRegistered<NotificationController>()) {
      final controller = Get.find<NotificationController>();
      controller.markAsRead(id);
    }

    final data = message.data;
    final type = data['type']?.toString();

    // Generic escape hatch: if the server tells us exactly which route to open,
    // honour it. Lets new server-side notifications deep-link without a client
    // release, as long as the screen exists in AppRoutes.
    final explicitScreen = data['screen']?.toString();

    String target = AppRoutes.notification;
    if (explicitScreen != null && explicitScreen.isNotEmpty) {
      target = explicitScreen;
    } else {
      switch (type) {
        case 'lab_request_created':
        case 'lab_request_reviewed':
          target = AppRoutes.patientLabRequests;
          break;
        case 'lab_report_uploaded':
          // Doctor-facing: route to doctor dashboard so they can pick the patient.
          target = AppRoutes.doctorDashboard;
          break;
        case 'transfusion_reminder':
        case 'transfusion_today':
        case 'missed_transfusion':
          target = AppRoutes.nextTransfusionDetails;
          break;
        case 'missed_transfusion_alert':
          // Staff/doctor side: open the specific patient if we have the id,
          // otherwise the doctor dashboard list.
          target = data['patientId'] != null
              ? AppRoutes.doctorPatientDetail
              : AppRoutes.doctorDashboard;
          break;
      }
    }

    // Forward useful entity ids to the destination screen via Get arguments.
    final arguments = <String, dynamic>{
      'fromNotification': true,
      'type': type,
      ...data, // raw payload — screens can pull patientId, transfusionId, etc.
    };

    // Async navigation logic — minimal & non-destructive
    Future.microtask(() async {
      try {
        const checkInterval = Duration(milliseconds: 250);
        const maxWait = Duration(seconds: 6);
        final stopwatch = Stopwatch()..start();

        // If we're NOT on splash right now, push immediately (common background case).
        if (Get.currentRoute != AppRoutes.splash) {
          if (Get.currentRoute != target) {
            try {
              await Get.toNamed(target, arguments: arguments);
            } catch (e) {
              if (kDebugMode) print('Immediate push failed: $e');
            }
          }
          return;
        }

        // Otherwise (likely terminated → launching) wait until the app leaves splash
        // or until timeout. Once it's NOT splash anymore, push notification on top.
        while (stopwatch.elapsed < maxWait &&
            Get.currentRoute == AppRoutes.splash) {
          await Future.delayed(checkInterval);
        }

        // If already on target (some other flow), nothing to do
        if (Get.currentRoute == target) return;

        // Now push target screen
        try {
          await Get.toNamed(target, arguments: arguments);
        } catch (e) {
          if (kDebugMode) print('Push after splash finished failed: $e');
        }
      } catch (e) {
        if (kDebugMode) print('Error in notification click flow: $e');
      }
    });
  }

  // Save notification to storage + update controller
  static void _saveNotification(RemoteMessage message) {
    final title = message.notification?.title ?? 'New Notification';
    final body = message.notification?.body ?? '';
    final id = _preferredMessageId(message);

    try {
      final current = NotificationStorage.getNotifications();

      // Dedupe by id
      final exists = current.any((n) => n.id == id);
      if (exists) {
        if (kDebugMode) print('Skipping duplicate notification: $id');
        // Still sync controller with storage controller
        if (Get.isRegistered<NotificationController>()) {
          final controller = Get.find<NotificationController>();
          // Replace controller list with storage to ensure consistent ordering/state
          controller.notifications.assignAll(current);
          controller.notifications.refresh();
        }
        return;
      }

      final newNotification = NotificationItem(
        id: id,
        title: title,
        message: body,
        date: DateFormat('MMM d, yyyy').format(DateTime.now()),
        isRead: false,
      );

      // Insert at top and persist
      current.insert(0, newNotification);
      NotificationStorage.saveNotifications(current);

      // Update controller
      if (Get.isRegistered<NotificationController>()) {
        final controller = Get.find<NotificationController>();
        // Defensive add: avoid duplicates inside controller
        final already = controller.notifications.any((n) => n.id == id);
        if (!already) {
          controller.addNotification(newNotification);
        } else {
          // If controller already had it, resync from storage to be safe
          controller.notifications.assignAll(current);
          controller.notifications.refresh();
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error saving notification: $e');
    }
  }

  // Helper to choose a stable id for deduping
  static String _preferredMessageId(RemoteMessage message) {
    final fromMessageId = message.messageId;
    if (fromMessageId != null && fromMessageId.isNotEmpty) return fromMessageId;
    final dataId = message.data['id']?.toString();
    if (dataId != null && dataId.isNotEmpty) return dataId;
    // Fallback: deterministic hash-like string using title/body/timestamp
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';
    final ts =
        message.sentTime?.millisecondsSinceEpoch ??
        DateTime.now().millisecondsSinceEpoch;
    return '${title.hashCode}_${body.hashCode}_$ts';
  }

  /// Idempotent token sync. Call at any point — login, app resume, after a
  /// permission grant. Reads the cached token, falls back to a fresh
  /// `getToken()` (with a short timeout so it never blocks UI for long), then
  /// POSTs the result to the backend.
  ///
  /// Designed to close the cold-start race: on a fresh install / device
  /// switch, the cache is empty and `getToken()` may not have resolved by the
  /// time login completes. Calling this post-login forces the registration
  /// to land regardless of how slow Firebase was during init.
  static Future<void> ensureTokenSynced() async {
    final box = GetStorage();
    final usertoken = box.read('token') ?? '';
    if (usertoken is! String || usertoken.isEmpty) {
      // Not logged in — nothing to sync against.
      return;
    }

    String? token = box.read<String>('fcmToken');
    if (token == null || token.isEmpty) {
      try {
        token = await _fcm.getToken().timeout(const Duration(seconds: 6));
      } on TimeoutException {
        if (kDebugMode) print('[FCM] ensureTokenSynced: getToken timed out');
        return;
      } catch (e, s) {
        await ErrorReportingService.recordError(
          e,
          s,
          tag: 'fcm.get_token',
        );
        return;
      }
      if (token == null || token.isEmpty) {
        if (kDebugMode) print('[FCM] ensureTokenSynced: token still null');
        return;
      }
      box.write('fcmToken', token);
    }

    await _sendTokenToBackend(token);
  }

  // Send the FCM token to backend if user is logged in
  static Future<void> _sendTokenToBackend(String token) async {
    final box = GetStorage();
    final usertoken = box.read('token') ?? ''; // auth token

    if (usertoken.isEmpty) {
      if (kDebugMode) {
        print('[FCM] Skipping send: User not logged in. Token=$token');
      }
      return;
    }

    try {
      if (kDebugMode) {
        final oldToken = box.read<String>('fcmToken');
        if (oldToken == token) {
          print('[FCM] Sending existing token to backend: $token');
        } else {
          print('[FCM] Sending fresh token to backend: $token');
        }
      }

      await ProfileUpdateService.updateFcmToken(token);

      if (kDebugMode) print('[FCM] Successfully sent token to backend.');
    } catch (e, s) {
      if (kDebugMode) print('[FCM] Failed to send token to backend: $e');
      await ErrorReportingService.recordError(
        e,
        s,
        tag: 'fcm.send_token',
      );
    }
  }

  // Show local notification using flutter_local_notifications
  static Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // Ensure Android channel exists for Android 8+
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
          );
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );
      await _flutterLocalNotificationsPlugin.show(
        _generateNotificationId(message),
        notification.title,
        notification.body,
        details,
        payload: message.messageId,
      );
    } catch (e) {
      if (kDebugMode) print('Error showing local notification: $e');
    }
  }

  // Generate small int id for local notifications (must be int)
  static int _generateNotificationId(RemoteMessage message) {
    final idStr = _preferredMessageId(message);
    // Simple deterministic conversion to int (may overflow but it's okay for id)
    return idStr.hashCode;
  }

  // This requests permission — call only from Dashboard/Home
  static Future<void> registerForNotificationsIfNeeded({
    bool force = false,
  }) async {
    final box = GetStorage();
    final askedBefore = box.read<bool>('fcmPermissionAsked') ?? false;
    if (askedBefore && !force) return;
    if (_permissionRequestInProgress) return;

    try {
      _permissionRequestInProgress = true;
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      box.write('fcmPermissionAsked', true);
      if (kDebugMode) {
        print('permission status: ${settings.authorizationStatus}');
      }
      // After granting, ensure token exists
      final token = await _fcm.getToken();
      if (token != null) {
        box.write('fcmToken', token);
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      if (kDebugMode) print('permission request error: $e');
    } finally {
      _permissionRequestInProgress = false;
    }
  }

  // Check for missed notifications (unread in storage) and update controller
  static Future<void> checkForMissedNotifications() async {
    try {
      // Get all notifications from storage
      final stored = NotificationStorage.getNotifications();

      // Check if there are any unread notifications
      final hasUnread = stored.any((notification) => !notification.isRead);

      if (hasUnread && Get.isRegistered<NotificationController>()) {
        final controller = Get.find<NotificationController>();
        controller.notifications.assignAll(stored);
        controller.notifications.refresh();
      }
    } catch (e) {
      if (kDebugMode) print('Error checking for missed notifications: $e');
    }
  }
}
