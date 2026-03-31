import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rudhirakshapp/controllers/dashboard_controller.dart';
import 'package:rudhirakshapp/controllers/global_profile_controller.dart';
import 'package:rudhirakshapp/controllers/theme_controller.dart';
import 'package:rudhirakshapp/data/services/push_notification_service.dart';
import 'app.dart';
// For locking orientation
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Ensure system UI overlays are visible (not full screen)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize GetStorage for local storage
  await GetStorage.init();

  // Initialize push notification service (non-blocking if Firebase not configured)
  try {
    await PushNotificationService.initializeCore();
    await PushNotificationService.checkForMissedNotifications();
  } catch (e) {
    debugPrint('Firebase/Notification init failed: $e');
  }

  // Initialize controllers
  Get.put(DashboardController());
  Get.put(GlobalProfileController());
  Get.put(ThemeController());

  runApp(const MyApp());
}
