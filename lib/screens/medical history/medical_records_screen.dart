import 'package:flutter/material.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/constants/app_strings.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'widgets/records_list.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: colors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              SolarLinearIcons.history,
              color: AppColors.historyAccent,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.medicalRecords,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: RecordsList(),
    );
  }
}
