import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import '../../../../controllers/notification_controller.dart';
import '../../../../core/theme/app_theme_colors.dart';

class SelectionBottomBar extends StatelessWidget {
  final NotificationController controller;
  const SelectionBottomBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final colors = AppThemeColors.of(context);

    return Obx(() {
      final selectedCount =
          controller.notifications.where((n) => n.isSelected).length;
      final allSelected = selectedCount == controller.notifications.length;

      return (controller.isSelectionMode.value && selectedCount > 0)
          ? Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.04,
                0,
                screenWidth * 0.04,
                MediaQuery.of(context).padding.bottom + screenHeight * 0.02,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(
                        allSelected
                            ? SolarLinearIcons.closeCircle
                            : SolarLinearIcons.checkCircle,
                        size: 18,
                      ),
                      label: Text(allSelected ? "Deselect" : "Select All"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.primaryColor,
                        side: BorderSide(
                          color: colors.primaryColor.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        controller.toggleSelectAll(!allSelected);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        SolarLinearIcons.trashBinMinimalistic,
                        size: 18,
                      ),
                      label: Text("Delete ($selectedCount)"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.errorColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        controller.deleteSelected();
                      },
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox();
    });
  }
}
