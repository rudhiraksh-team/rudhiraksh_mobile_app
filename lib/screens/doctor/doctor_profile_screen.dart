import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/controllers/doctor_profile_controller.dart';
import 'package:rudhirakshapp/controllers/logout_controller.dart';
import 'package:rudhirakshapp/data/helper%20function/navigation_helper.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorProfileController());
    final logoutController = Get.put(LogoutController());
    final colors = AppThemeColors.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final isEditing = false.obs;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: Obx(() {
        if (controller.isLoading.value && controller.profileData.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: colors.primaryColor),
          );
        }

        return RefreshIndicator(
          color: colors.primaryColor,
          onRefresh: () => controller.fetchProfile(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // Gradient Header with avatar
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
                            color: colors.primaryColor.withValues(alpha: 0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: colors.primaryColor,
                        child: Text(
                          controller.initials,
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

              // Name & role
              Obx(() => Text(
                    controller.doctorName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  )),
              const SizedBox(height: 6),
              Center(
                child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: colors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        controller.roleName,
                        style: TextStyle(
                          color: colors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )),
              ),

              const SizedBox(height: 24),

              // Profile Info Card with edit toggle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Obx(() => Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with edit/cancel toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(SolarLinearIcons.userRounded,
                                      size: 18,
                                      color: colors.primaryColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Profile Details',
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              if (!isEditing.value)
                                GestureDetector(
                                  onTap: () => isEditing.value = true,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: colors.primaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(SolarLinearIcons.pen,
                                            size: 14,
                                            color: colors.primaryColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: colors.primaryColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                GestureDetector(
                                  onTap: () {
                                    controller.resetControllers();
                                    isEditing.value = false;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.error.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(SolarLinearIcons.closeCircle,
                                            size: 14,
                                            color: AppColors.error),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: AppColors.error,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (!isEditing.value) ...[
                            // Read-only view
                            _ProfileRow(
                              icon: SolarLinearIcons.userRounded,
                              label: 'Name',
                              value: controller.doctorName.isNotEmpty
                                  ? controller.doctorName
                                  : 'Not set',
                              colors: colors,
                            ),
                            Divider(color: colors.dividerColor, height: 24),
                            _ProfileRow(
                              icon: SolarLinearIcons.letter,
                              label: 'Email',
                              value: controller.doctorEmail.isNotEmpty
                                  ? controller.doctorEmail
                                  : 'Not set',
                              colors: colors,
                            ),
                            Divider(color: colors.dividerColor, height: 24),
                            _ProfileRow(
                              icon: SolarLinearIcons.phone,
                              label: 'Phone',
                              value: controller.doctorPhone.isNotEmpty
                                  ? controller.doctorPhone
                                  : 'Not set',
                              colors: colors,
                            ),
                            Divider(color: colors.dividerColor, height: 24),
                            _ProfileRow(
                              icon: SolarLinearIcons.buildings2,
                              label: 'Blood Bank',
                              value: controller.bloodBankName.isNotEmpty
                                  ? controller.bloodBankName
                                  : 'Not assigned',
                              colors: colors,
                            ),
                          ] else ...[
                            // Edit view
                            _EditField(
                              controller: controller.nameController,
                              label: 'Name',
                              icon: SolarLinearIcons.userRounded,
                              colors: colors,
                            ),
                            const SizedBox(height: 12),
                            _EditField(
                              controller: controller.phoneController,
                              label: 'Phone (10 digits)',
                              icon: SolarLinearIcons.phone,
                              keyboardType: TextInputType.phone,
                              colors: colors,
                            ),
                            const SizedBox(height: 16),

                            // Email & Blood Bank (non-editable info)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(SolarLinearIcons.infoCircle,
                                      size: 16,
                                      color: colors.textSecondary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Email and Blood Bank cannot be changed here.',
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Save button
                            SizedBox(
                              width: double.infinity,
                              child: Obx(() => ElevatedButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : () async {
                                            await controller.updateProfile();
                                            isEditing.value = false;
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.brandCrimson,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: AppColors
                                          .brandCrimson
                                          .withValues(alpha: 0.5),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Save Changes',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  )),
                            ),
                          ],
                        ],
                      ),
                    )),
              ),

              const SizedBox(height: 20),

              // Action buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  children: [
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
                            color:
                                colors.primaryColor.withValues(alpha: 0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => logoutController.logoutImmediate(),
                        icon: const Icon(SolarLinearIcons.logout2, size: 20),
                        label: const Text(
                          'Logout',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final AppThemeColors colors;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colors.primaryColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final AppThemeColors colors;

  const _EditField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: colors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: colors.primaryColor),
        filled: true,
        fillColor: colors.backgroundColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primaryColor, width: 1.5),
        ),
      ),
    );
  }
}
