import 'package:flutter/material.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/constants/app_strings.dart';

class SplashText extends StatelessWidget {
  final double fontSize;
  final double screenHeight;

  const SplashText({
    super.key,
    required this.fontSize,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              AppColors.lightPrimary,
              AppColors.lightSecondary,
            ],
          ).createShader(bounds),
          child: Text(
            AppStrings.appName,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.008),
        Text(
          AppStrings.appTagline,
          style: TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: fontSize * 0.38,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
