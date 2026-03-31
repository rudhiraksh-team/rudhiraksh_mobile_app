import 'package:flutter/material.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/core/widgets/custom_back_button.dart';
import 'package:rudhirakshapp/screens/transfusion%20details/widgets/call_button.dart';

import 'widgets/transfusion_info_card.dart';
import 'widgets/preparation_guidelines_card.dart';

class NextTransfusionDetailsScreen extends StatelessWidget {
  const NextTransfusionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: colors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        leading: const CustomBackButton(),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              SolarLinearIcons.calendarMark,
              color: AppColors.transfusionAccent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "Next Transfusion",
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: screenWidth * 0.048,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: 12,
        ),
        child: Column(
          children: [
            const TransfusionInfoCard(),
            const SizedBox(height: 12),
            const PreparationGuidelinesCard(),
            const Spacer(),
            const CallButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
