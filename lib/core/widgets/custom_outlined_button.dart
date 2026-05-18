import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_typography.dart';
import '../../core/theme/app_theme_colors.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? borderColor;
  final Color? textColor;
  final double? fontSize;
  final double? verticalPadding;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.borderColor,
    this.textColor,
    this.fontSize,
    this.verticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding ?? MediaQuery.of(context).size.height * 0.02,
          ),
          side: BorderSide(
            color: borderColor ?? colors.primaryColor,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.paddingMedium),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTypography.body(context).copyWith(
            color: textColor ?? colors.primaryColor,
            fontSize: fontSize ?? MediaQuery.of(context).size.width * 0.04,
          ),
        ),
      ),
    );
  }
}
