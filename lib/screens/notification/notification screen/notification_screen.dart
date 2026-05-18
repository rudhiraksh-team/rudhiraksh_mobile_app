// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/routes/app_routes.dart';
import '../../../controllers/notification_controller.dart';
// Widgets import
import 'widgets/notification_app_bar.dart';
import 'widgets/notification_list.dart';
import 'widgets/selection_bottom_bar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());
    final colors = AppThemeColors.of(context);
    final arguments = Get.arguments;

    return WillPopScope(
      onWillPop: () async {
        if (controller.isSelectionMode.value) {
          controller.clearSelection();
          return false;
        }

        // If came from notification, go directly to dashboard
        if (arguments != null && arguments['fromNotification'] == true) {
          Get.offAllNamed(AppRoutes.dashboard);
          return false;
        }

        return true;
      },
      child: Scaffold(
        backgroundColor: colors.backgroundColor,
        appBar: NotificationAppBar(
          controller: controller,
          // Check if navigated from notification
          fromNotification:
              arguments != null && arguments['fromNotification'] == true,
        ),
        body: NotificationList(controller: controller),
        bottomNavigationBar: SelectionBottomBar(controller: controller),
      ),
    );
  }
}
