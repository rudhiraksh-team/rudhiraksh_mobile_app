import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:rudhirakshapp/controllers/connectivity_controller.dart';
import 'package:rudhirakshapp/core/constants/app_radius.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/core/widgets/custom_elevated_button.dart';

/// Full-screen blocking state shown app-wide whenever the device has no
/// network connectivity. Wired in via [GetMaterialApp.builder] so it overlays
/// whatever route is active and disappears automatically once the connection
/// returns.
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final connectivity = Get.find<ConnectivityController>();

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: colors.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                  ),
                  child: Icon(
                    SolarIconsOutline.wifiRouter,
                    size: 44,
                    color: colors.errorColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Internet Connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check your Wi-Fi or mobile data connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                Obx(
                  () => CustomElevatedButton(
                    label: 'Try Again',
                    isLoading: connectivity.isChecking.value,
                    onPressed: connectivity.retry,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
