import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/utils/string_utils.dart';
import 'package:rudhirakshapp/data/helper%20function/navigation_helper.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';

class DashboardAppBar extends StatelessWidget {
  final DashboardController controller;
  const DashboardAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final isDark = colors.isDark;

    // PDF requirement #9: gradient header with blood bank logo + name + notification bell
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? AppColors.headerGradientDark : AppColors.headerGradient,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // Blood Bank Avatar
          Obx(
            () => GestureDetector(
              onTap: () {
                // Navigate to blood bank info
                NavigationHelper.goToBloodBankInfo();
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withValues(alpha: 0.2),
                  image: controller.bloodBankPhoto.value.isNotEmpty
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(
                            controller.bloodBankPhoto.value,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: controller.bloodBankPhoto.value.isEmpty
                    ? const Icon(
                        SolarLinearIcons.buildings,
                        size: 20,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.bloodBankName.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Obx(
                  () => Text(
                    "Hi, ${StringUtils.getFirstName(controller.userName.value)}",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notification Icon
          GestureDetector(
            onTap: NavigationHelper.goToNotificationScreen,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                SolarLinearIcons.bellBing,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
