import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';

class CustomBackButton extends StatelessWidget {
  final double iconSize;
  final VoidCallback? onPressed;

  const CustomBackButton({super.key, this.iconSize = 20, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return GestureDetector(
      onTap: onPressed ?? () => Get.back(),
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colors.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          SolarLinearIcons.altArrowLeft,
          color: colors.primaryColor,
          size: iconSize,
        ),
      ),
    );
  }
}
