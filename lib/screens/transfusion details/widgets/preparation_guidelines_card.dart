// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';

class PreparationGuidelinesCard extends StatelessWidget {
  const PreparationGuidelinesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                SolarLinearIcons.checklist,
                color: AppColors.emerald,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                "Before You Go",
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _tipChip(colors, SolarLinearIcons.waterdrop, "Stay hydrated"),
              _tipChip(colors, SolarLinearIcons.card, "Bring ID card"),
              _tipChip(colors, SolarLinearIcons.tShirt, "Comfortable clothes"),
              _tipChip(colors, SolarLinearIcons.clockCircle, "Arrive early"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tipChip(AppThemeColors colors, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.emerald.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.emerald),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
