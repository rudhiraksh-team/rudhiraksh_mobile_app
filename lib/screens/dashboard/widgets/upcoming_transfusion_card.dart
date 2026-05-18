// ignore_for_file: library_private_types_in_public_api, unused_local_variable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/enums/transfusion_status.dart';
import 'package:rudhirakshapp/data/helper%20function/navigation_helper.dart';
import '../../../core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/data/models/transfusion_list_model.dart'
    as tmodel;

class UpcomingTransfusionCardWidget extends StatelessWidget {
  final tmodel.Transfusion transfusion;
  final TransfusionStatus status;

  const UpcomingTransfusionCardWidget({
    super.key,
    required this.transfusion,
    required this.status,
  });

  String formatDateOnly(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('dd MMM yyyy').format(dt);
  }

  String _formatTimeOnly(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    String statusText;
    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case TransfusionStatus.upcoming:
        statusText = "Upcoming";
        statusColor = AppColors.transfusionAccent;
        statusIcon = SolarLinearIcons.clockCircle;
        break;
      case TransfusionStatus.missed:
        statusText = "Missed";
        statusColor = AppColors.error;
        statusIcon = SolarLinearIcons.closeCircle;
        break;
      case TransfusionStatus.done:
        statusColor = AppColors.success;
        statusText = "Completed";
        statusIcon = SolarLinearIcons.checkCircle;
        break;
    }

    final displayDate =
        (status == TransfusionStatus.upcoming &&
                transfusion.nextTransfusionDate != null)
            ? formatDateOnly(transfusion.nextTransfusionDate)
            : (transfusion.visitDate != null
                ? formatDateOnly(transfusion.visitDate)
                : '-');

    final timeText =
        (status == TransfusionStatus.upcoming)
            ? (transfusion.nextTransfusionDate != null
                ? _formatTimeOnly(transfusion.nextTransfusionDate)
                : '')
            : (status == TransfusionStatus.missed)
            ? (transfusion.nextTransfusionDate != null
                ? _formatTimeOnly(transfusion.nextTransfusionDate)
                : '')
            : (transfusion.visitDate != null
                ? _formatTimeOnly(transfusion.visitDate)
                : '');

    final staffName = transfusion.attendingStaff?.fullName ?? '';

    final rawNotes = (transfusion.notes ?? '').replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '').trim();
    final notes =
        rawNotes.isNotEmpty
            ? rawNotes
            : (status == TransfusionStatus.upcoming
                ? "Please arrive a few minutes early for your transfusion."
                : status == TransfusionStatus.missed
                ? "You missed your transfusion."
                : "No additional details.");

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
      decoration: BoxDecoration(
        color: colors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: isSmallScreen ? 12 : 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (staffName.isNotEmpty)
                Text(
                  'By $staffName',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: isSmallScreen ? 11 : 12,
                  ),
                ),
            ],
          ),

          SizedBox(height: isSmallScreen ? 10 : 14),

          // Date & Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayDate,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (timeText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          SolarLinearIcons.clockCircle,
                          size: 14,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeText,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: isSmallScreen ? 12 : 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 10 : 14,
                  vertical: isSmallScreen ? 5 : 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: isSmallScreen ? 10 : 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isSmallScreen ? 10 : 14),

          // Notes
          Text(
            notes,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: isSmallScreen ? 12 : 14,
              height: 1.4,
            ),
          ),

          if (status == TransfusionStatus.upcoming) ...[
            SizedBox(height: isSmallScreen ? 12 : 16),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.transfusionAccent,
                      AppColors.lightPrimary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.transfusionAccent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 12 : 14,
                    ),
                  ),
                  onPressed: NavigationHelper.goToNextTransfusionDetails,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "View Details",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        SolarLinearIcons.altArrowRight,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
