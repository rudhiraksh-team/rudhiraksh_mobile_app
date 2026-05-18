import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/widgets/custom_back_button.dart';
import 'package:rudhirakshapp/routes/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../controllers/notification_controller.dart';

class NotificationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final NotificationController controller;
  final bool fromNotification;

  const NotificationAppBar({
    super.key,
    required this.controller,
    required this.fromNotification,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: colors.backgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: CustomBackButton(
        onPressed: () {
          if (controller.isSelectionMode.value) {
            controller.clearSelection();
          } else if (fromNotification) {
            Get.offAllNamed(AppRoutes.dashboard);
          } else {
            Get.back();
          }
        },
      ),
      title: Obx(
        () => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!controller.isSelectionMode.value)
              Icon(
                SolarLinearIcons.bell,
                color: AppColors.notifAccent,
                size: 20,
              ),
            if (!controller.isSelectionMode.value) const SizedBox(width: 8),
            Text(
              controller.isSelectionMode.value
                  ? "${controller.notifications.where((n) => n.isSelected).length} Selected"
                  : "Notifications",
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Obx(() {
          if (controller.isSelectionMode.value) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => controller.deleteSelected(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    SolarLinearIcons.trashBinMinimalistic,
                    color: colors.errorColor,
                    size: 20,
                  ),
                ),
              ),
            );
          }

          final hasUnread = controller.notifications.any((n) => !n.isRead);
          if (!hasUnread) return const SizedBox();

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                controller.markAllAsRead();
                Get.snackbar(
                  'Notifications',
                  'All marked as read',
                  duration: const Duration(seconds: 2),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.notifAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  SolarLinearIcons.checkRead,
                  color: AppColors.notifAccent,
                  size: 20,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
