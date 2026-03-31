import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/data/models/transfusion_list_model.dart';
import 'package:rudhirakshapp/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';

class RecordItem extends StatelessWidget {
  final Transfusion record;
  final String status;

  const RecordItem({super.key, required this.record, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case "Upcoming":
        statusColor = AppColors.upcoming;
        statusIcon = SolarLinearIcons.clockCircle;
        break;
      case "Missed":
        statusColor = AppColors.error;
        statusIcon = SolarLinearIcons.closeCircle;
        break;
      default:
        statusColor = AppColors.success;
        statusIcon = SolarLinearIcons.checkCircle;
    }

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.transfusionRecordDetail,
          arguments: {'record': record, 'status': status},
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenWidth * 0.025),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.15),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Status icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                SolarLinearIcons.heartPulse,
                color: statusColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (status == "Done" && record.id != null)
                    Text(
                      "Transfusion #${record.id}",
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  Text(
                    record.unitBloodGroup ?? "-",
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.visitDateFormatted,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 12, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
