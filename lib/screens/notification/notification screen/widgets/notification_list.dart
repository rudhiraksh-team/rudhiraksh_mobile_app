// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import '../../../../controllers/notification_controller.dart';
import '../../../../core/theme/app_theme_colors.dart';

class NotificationList extends StatelessWidget {
  final NotificationController controller;
  const NotificationList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final colors = AppThemeColors.of(context);

    return Obx(() {
      if (controller.notifications.isEmpty) {
        return RefreshIndicator(
          color: AppColors.notifAccent,
          onRefresh: controller.refreshFromServer,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: screenHeight * 0.2),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.notifAccent.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        SolarLinearIcons.bellOff,
                        color: AppColors.notifAccent.withValues(alpha: 0.5),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No notifications yet",
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "We'll notify you about your transfusions",
                      style: TextStyle(
                        color: colors.textSecondary.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      final sortedNotifications = controller.notifications.toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      return RefreshIndicator(
        color: AppColors.notifAccent,
        onRefresh: controller.refreshFromServer,
        child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.04,
          screenHeight * 0.01,
          screenWidth * 0.04,
          screenHeight * 0.01 + MediaQuery.of(context).padding.bottom,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: sortedNotifications.length,
        itemBuilder: (context, index) {
          final item = sortedNotifications[index];
          return GestureDetector(
            onLongPress: () {
              controller.isSelectionMode.value = true;
              controller.toggleNotificationSelection(index);
            },
            onTap: () {
              if (controller.isSelectionMode.value) {
                controller.toggleNotificationSelection(index);
              } else {
                controller.markAsRead(item.id);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(bottom: screenWidth * 0.025),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: item.isSelected
                    ? AppColors.notifAccent.withValues(alpha: 0.08)
                    : !item.isRead
                        ? AppColors.notifAccent.withValues(alpha: 0.04)
                        : colors.surfaceColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: item.isSelected
                      ? AppColors.notifAccent.withValues(alpha: 0.3)
                      : colors.borderColor,
                  width: item.isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: !item.isRead
                          ? AppColors.notifAccent.withValues(alpha: 0.1)
                          : colors.textSecondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      SolarLinearIcons.bellBing,
                      size: 18,
                      color: !item.isRead
                          ? AppColors.notifAccent
                          : colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: colors.textPrimary,
                                  fontWeight:
                                      !item.isRead ? FontWeight.w700 : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (!item.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.notifAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.message,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.date,
                          style: TextStyle(
                            color: colors.textSecondary.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        ),
      );
    });
  }
}
