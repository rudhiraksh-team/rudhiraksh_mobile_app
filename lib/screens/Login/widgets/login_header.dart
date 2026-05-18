import 'package:flutter/material.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/constants/app_strings.dart';
import '../../../core/theme/app_theme_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final colors = AppThemeColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              AppColors.brandCrimson,
              AppColors.brandRed,
            ],
          ).createShader(bounds),
          child: Text(
            AppStrings.welcomeMessage,
            style: TextStyle(
              fontSize: screenWidth * 0.075,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.loginMessage,
          style: TextStyle(
            fontSize: screenWidth * 0.038,
            color: colors.textSecondary,
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
