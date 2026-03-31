// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/controllers/dashboard_controller.dart';
import 'package:rudhirakshapp/controllers/global_profile_controller.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/data/models/blood_bank_model.dart';
import 'package:rudhirakshapp/data/models/transfusion_list_model.dart'
    as tmodel;
import '../../../core/theme/app_theme_colors.dart';

class TransfusionInfoCard extends StatelessWidget {
  const TransfusionInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    var bloodBankName = "Not Available";
    var bloodBankAddress = "Not Available";
    var bloodBankContact = "Not Available";
    final globalProfile = Get.find<GlobalProfileController>();
    final controller = Get.find<DashboardController>();

    tmodel.Transfusion? upcomingTransfusion =
        controller.upcomingTransfusion.value;

    String bloodGroup = "-";
    final patientData = globalProfile.profileData['data']?['patient'];
    if (patientData != null && patientData is Map<String, dynamic>) {
      bloodGroup = patientData['blood_group'] ?? "-";
    }

    final dateFmt = DateFormat('dd MMM yyyy');
    final timeFmt = DateFormat('hh:mm a');

    String dateDisplay = 'No upcoming';
    String timeDisplay = '';
    String attendingName = 'N/A';

    if (globalProfile.bloodBankData.isNotEmpty) {
      final bank = BloodBank.fromJson(
        Map<String, dynamic>.from(globalProfile.bloodBankData),
      );
      bloodBankName = bank.name;
      bloodBankAddress = bank.address;
      bloodBankContact = bank.contactPhone ?? "Not Available";
    }

    if (upcomingTransfusion != null) {
      DateTime? dt = upcomingTransfusion.nextTransfusionDate ??
          upcomingTransfusion.startTime ??
          upcomingTransfusion.visitDate;

      if (dt != null) {
        dateDisplay = dateFmt.format(dt);
        timeDisplay = timeFmt.format(dt);
      } else {
        if ((upcomingTransfusion.visitDateFormatted).isNotEmpty &&
            upcomingTransfusion.visitDateFormatted != '-') {
          dateDisplay = upcomingTransfusion.visitDateFormatted;
        } else if ((upcomingTransfusion.startTimeFormatted).isNotEmpty &&
            upcomingTransfusion.startTimeFormatted != '-') {
          dateDisplay = upcomingTransfusion.startTimeFormatted;
        }
      }

      String? candidate =
          upcomingTransfusion.attendingStaff?.fullName?.trim();
      if (candidate == null || candidate.isEmpty) {
        final anyWithStaff = controller.doneTransfusions.firstWhereOrNull(
          (t) => t.attendingStaff?.fullName?.trim().isNotEmpty == true,
        );
        candidate = anyWithStaff?.attendingStaff?.fullName?.trim();
      }
      attendingName =
          (candidate != null && candidate.isNotEmpty) ? candidate : 'N/A';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Date hero row ---
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.transfusionAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  SolarLinearIcons.calendar,
                  color: AppColors.transfusionAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateDisplay,
                      style: TextStyle(
                        fontSize: 18,
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (timeDisplay.isNotEmpty)
                      Text(
                        timeDisplay,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.coral.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  bloodGroup,
                  style: const TextStyle(
                    color: AppColors.coral,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Container(height: 1, color: colors.dividerColor),
          const SizedBox(height: 14),

          // --- Compact 2-column grid ---
          Row(
            children: [
              Expanded(
                child: _compactDetail(
                  colors,
                  SolarLinearIcons.hospital,
                  "Blood Bank",
                  bloodBankName,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _compactDetail(
                  colors,
                  SolarLinearIcons.stethoscope,
                  "Doctor",
                  attendingName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _compactDetail(
                  colors,
                  SolarLinearIcons.mapPoint,
                  "Address",
                  bloodBankAddress,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _compactDetail(
                  colors,
                  SolarLinearIcons.phone,
                  "Contact",
                  bloodBankContact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compactDetail(
    AppThemeColors colors,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.transfusionAccent),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
