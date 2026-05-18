import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';

import '../../controllers/edit_emergency_contacts_controller.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/widgets/custom_modern_text_field.dart';

class EditEmergencyContactsScreen extends StatelessWidget {
  const EditEmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditEmergencyContactsController());
    final colors = AppThemeColors.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: colors.backgroundColor,
        elevation: 0,
        title: Text(
          'Edit Emergency Contacts',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 8),
              _sectionLabel('Primary Contact', colors),
              const SizedBox(height: 12),
              ModernTextField(
                labelText: 'Name',
                controller: controller.name1Controller,
                prefixIcon: SolarLinearIcons.user,
                screenWidth: screenWidth,
              ),
              const SizedBox(height: 12),
              ModernTextField(
                labelText: 'Relation',
                controller: controller.relationship1Controller,
                prefixIcon: SolarLinearIcons.usersGroupRounded,
                screenWidth: screenWidth,
              ),
              const SizedBox(height: 12),
              Obx(() => IntlPhoneField(
                    controller: controller.phone1Controller,
                    decoration: _intlPhoneDecoration(
                      'Phone',
                      controller.phone1Error.value,
                      colors,
                    ),
                    initialCountryCode: 'IN',
                    invalidNumberMessage: 'Enter a valid mobile number',
                    onCountryChanged: (country) {
                      controller.countryCode1 = '+${country.dialCode}';
                    },
                  )),
              const SizedBox(height: 24),
              _sectionLabel('Secondary Contact (Optional)', colors),
              const SizedBox(height: 12),
              ModernTextField(
                labelText: 'Name',
                controller: controller.name2Controller,
                prefixIcon: SolarLinearIcons.user,
                screenWidth: screenWidth,
              ),
              const SizedBox(height: 12),
              ModernTextField(
                labelText: 'Relation',
                controller: controller.relationship2Controller,
                prefixIcon: SolarLinearIcons.usersGroupRounded,
                screenWidth: screenWidth,
              ),
              const SizedBox(height: 12),
              Obx(() => IntlPhoneField(
                    controller: controller.phone2Controller,
                    decoration: _intlPhoneDecoration(
                      'Phone',
                      controller.phone2Error.value,
                      colors,
                    ),
                    initialCountryCode: 'IN',
                    invalidNumberMessage: 'Enter a valid mobile number',
                    onCountryChanged: (country) {
                      controller.countryCode2 = '+${country.dialCode}';
                    },
                  )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 12,
          ),
          child: Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
                          'Save',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              )),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, AppThemeColors colors) {
    return Text(
      text,
      style: TextStyle(
        color: colors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }

  InputDecoration _intlPhoneDecoration(
    String label,
    String? errorText,
    AppThemeColors colors,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: colors.textSecondary,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: colors.isDark
          ? Colors.white.withValues(alpha: 0.05)
          : colors.primaryColor.withValues(alpha: 0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colors.primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.errorColor, width: 2),
      ),
      errorText: errorText,
      errorStyle: TextStyle(
        color: colors.errorColor,
        fontWeight: FontWeight.w400,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
    );
  }
}
