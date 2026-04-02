// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/controllers/dashboard_controller.dart';
import 'package:rudhirakshapp/controllers/global_profile_controller.dart';
import 'package:rudhirakshapp/controllers/logout_controller.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/data/helper%20function/navigation_helper.dart';

import '../../controllers/profile_review_controller.dart';
import 'widgets/profile_glass_card.dart';

class ProfileReviewScreen extends StatelessWidget {
  final bool isFromDashboard;
  const ProfileReviewScreen({super.key, this.isFromDashboard = false});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileReviewController());
    final globalProfile = Get.find<GlobalProfileController>();
    final dashboardController = Get.find<DashboardController>();
    final logoutController = Get.put(LogoutController());

    final bool fromDashboard = isFromDashboard;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colors.primaryColor),
          );
        }

        Widget content = RefreshIndicator(
          color: colors.primaryColor,
          onRefresh: () async {
            if (fromDashboard) {
              await globalProfile.refreshProfile();
              controller.onInit();
            }
          },
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              Obx(() {
                if (globalProfile.profileData.isEmpty) {
                  return SizedBox(
                    height: screenHeight,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            SolarLinearIcons.userRounded,
                            size: 48,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Profile data not available",
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  dashboardController.setProfileAndBloodBankData(
                    globalProfile.profileData,
                    globalProfile.bloodBankData,
                  );
                });

                final statusBarHeight =
                    MediaQuery.of(context).padding.top;

                return Column(
                  children: [
                    // Gradient Header
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          width: screenWidth,
                          height: 160 + statusBarHeight,
                          padding: EdgeInsets.only(top: statusBarHeight),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.brandCrimson,
                                AppColors.brandRed,
                                AppColors.brandRose.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -50,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.backgroundColor,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      colors.primaryColor.withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: colors.primaryColor,
                              child: Text(
                                _getInitials(controller.nameController.text),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    Text(
                      controller.nameController.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        controller.bloodGroupController.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                      ),
                      child: Column(
                        children: [
                          ProfileGlassCard(
                            controller: controller,
                            colors: colors,
                          ),
                          const SizedBox(height: 20),

                          // Blood Bank Info button
                          if (fromDashboard)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: NavigationHelper.goToBloodBankInfo,
                                icon: Icon(
                                  SolarLinearIcons.buildings2,
                                  size: 20,
                                  color: colors.primaryColor,
                                ),
                                label: Text(
                                  'Blood Bank Info',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: colors.primaryColor,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: colors.primaryColor.withValues(alpha: 0.3),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          if (fromDashboard) const SizedBox(height: 10),

                          // Terms & Conditions button
                          if (fromDashboard)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: NavigationHelper.goToTerms,
                                icon: Icon(
                                  SolarLinearIcons.document,
                                  size: 20,
                                  color: colors.primaryColor,
                                ),
                                label: Text(
                                  'Terms & Privacy Policy',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: colors.primaryColor,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: colors.primaryColor.withValues(alpha: 0.3),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          if (fromDashboard) const SizedBox(height: 10),

                          // Logout button
                          if (fromDashboard)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    logoutController.logoutImmediate(),
                                icon: const Icon(
                                  SolarLinearIcons.logout2,
                                  size: 20,
                                ),
                                label: const Text(
                                  'Logout',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: BorderSide(
                                    color: AppColors.error.withValues(alpha: 0.3),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        );

        return content;
      }),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }
    return (nameParts[0][0] + nameParts[nameParts.length - 1][0]).toUpperCase();
  }
}
