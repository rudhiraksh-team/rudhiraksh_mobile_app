import 'package:flutter/material.dart';
import 'package:rudhirakshapp/core/constants/app_assets.dart';

class SplashLogo extends StatelessWidget {
  final double logoSize;
  const SplashLogo({super.key, required this.logoSize});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.splash,
      height: logoSize,
      width: logoSize,
    );
  }
}
