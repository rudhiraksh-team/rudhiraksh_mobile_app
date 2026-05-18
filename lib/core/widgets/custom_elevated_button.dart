import 'package:flutter/material.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import '../theme/app_theme_colors.dart';

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? fontSize;
  final double? verticalPadding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;

  const CustomElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fontSize,
    this.verticalPadding,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final bgColor = backgroundColor ?? colors.primaryColor;

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: backgroundColor == null
              ? LinearGradient(
                  colors: [
                    AppColors.lightPrimary,
                    AppColors.lightSecondary,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 16),
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: verticalPadding ?? 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
            ),
            elevation: 0,
          ),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  height: fontSize ?? screenWidth * 0.045,
                  width: fontSize ?? screenWidth * 0.045,
                  child: CircularProgressIndicator(
                    color: textColor ?? AppColors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : (icon == null
                  ? Text(
                      label,
                      style: TextStyle(
                        fontSize: fontSize ?? screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: textColor ?? AppColors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: textColor ?? AppColors.white),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: fontSize ?? screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                            color: textColor ?? AppColors.white,
                          ),
                        ),
                      ],
                    )),
        ),
      ),
    );
  }
}
