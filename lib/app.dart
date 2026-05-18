import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudhirakshapp/core/constants/app_strings.dart';
import 'package:rudhirakshapp/data/services/app_update_service.dart';
import 'package:rudhirakshapp/data/services/push_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'controllers/theme_controller.dart';
import 'routes/app_routes.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Run after the first frame so we never block startup paint.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ignore: discarded_futures
      AppUpdateService.checkForUpdate();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // On every foreground, reconcile the FCM token with the backend.
    // Catches: permission toggled on in Settings while backgrounded, token
    // rotation that fired while the app was killed, fresh install where
    // login already happened but the first sync raced.
    if (state == AppLifecycleState.resumed) {
      // Fire-and-forget — never block UI on a network call here.
      // ignore: discarded_futures
      PushNotificationService.ensureTokenSynced();
      // Catch users who backgrounded for hours — debounce inside the service
      // keeps this from re-running on every quick foreground.
      // ignore: discarded_futures
      AppUpdateService.checkForUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.routes,
      ),
    );
  }
}
