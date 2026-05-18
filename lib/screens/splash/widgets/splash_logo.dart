import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';

class SplashLogo extends StatelessWidget {
  final double logoSize;
  const SplashLogo({super.key, required this.logoSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brandCrimson,
            AppColors.brandRed,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandCrimson.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/logo/svg/rudhiraksh-logo-icon-mono.svg',
          width: logoSize * 0.55,
          height: logoSize * 0.55,
        ),
      ),
    );
  }
}
