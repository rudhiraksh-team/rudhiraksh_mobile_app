import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/widgets/custom_modern_text_field.dart';
import '../../../controllers/profile_review_controller.dart';
import '../../../core/theme/app_theme_colors.dart';

class ProfileGlassCard extends StatelessWidget {
  final ProfileReviewController controller;
  final AppThemeColors colors;

  ProfileGlassCard({
    super.key,
    required this.controller,
    required this.colors,
  });

  final RxBool isAddressEditing = false.obs;
  final RxBool isEmergencyEditing = false.obs;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        _buildSection(
          icon: SolarLinearIcons.userCircle,
          title: "Personal Information",
          locked: true,
          accentColor: AppColors.profileAccent,
          children: [
            _buildInfoRow(SolarLinearIcons.user, "Name",
                controller.nameController.text),
            _buildInfoRow(SolarLinearIcons.calendar, "Date of Birth",
                controller.dobController.text),
            _buildInfoRow(SolarLinearIcons.usersGroupRounded, "Gender",
                controller.genderController.text),
            _buildInfoRow(SolarLinearIcons.heartPulse, "Blood Group",
                controller.bloodGroupController.text),
          ],
        ),

        const SizedBox(height: 14),

        _buildSection(
          icon: SolarLinearIcons.phone,
          title: "Contact Information",
          locked: true,
          accentColor: AppColors.transfusionAccent,
          children: [
            _buildInfoRow(SolarLinearIcons.letter, "Email",
                controller.emailController.text.trim()),
            _buildInfoRow(SolarLinearIcons.phone, "Phone",
                '+91 ${controller.contactController.text.trim()}'),
            _buildInfoRow(SolarLinearIcons.buildings, "Blood Bank",
                controller.bloodBaankNameController.text),
          ],
        ),

        const SizedBox(height: 14),

        Obx(() => _buildEditableSection(
              icon: SolarLinearIcons.mapPoint,
              title: "Address",
              isEditing: isAddressEditing.value,
              accentColor: AppColors.sky,
              onEdit: () => isAddressEditing.value = true,
              onCancel: () => isAddressEditing.value = false,
              onSave: () {
                controller.saveProfile(fromDashboard: true);
                isAddressEditing.value = false;
              },
              readOnlyChildren: [
                _buildInfoRow(
                    SolarLinearIcons.streetsMapPoint,
                    "Street",
                    controller.addressStreetController.text.isEmpty
                        ? "Not set"
                        : controller.addressStreetController.text),
                _buildInfoRow(
                    SolarLinearIcons.map,
                    "Area",
                    controller.addressAreaController.text.isEmpty
                        ? "Not set"
                        : controller.addressAreaController.text),
                _buildInfoRow(
                    SolarLinearIcons.buildings2,
                    "City",
                    controller.addressCityController.text.isEmpty
                        ? "Not set"
                        : controller.addressCityController.text),
                _buildInfoRow(
                    SolarLinearIcons.mapPoint,
                    "State",
                    controller.addressStateController.text.isEmpty
                        ? "Not set"
                        : controller.addressStateController.text),
                _buildInfoRow(
                    SolarLinearIcons.mapPointWave,
                    "Pincode",
                    controller.addressPincodeController.text.isEmpty
                        ? "Not set"
                        : controller.addressPincodeController.text),
              ],
              editChildren: [
                Obx(
                  () => ModernTextField(
                    labelText: "Street",
                    controller: controller.addressStreetController,
                    prefixIcon: SolarLinearIcons.streetsMapPoint,
                    screenWidth: screenWidth,
                    keyboardType: TextInputType.streetAddress,
                    errorText: controller.addressStreetError.value,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => ModernTextField(
                    labelText: "Area",
                    controller: controller.addressAreaController,
                    prefixIcon: SolarLinearIcons.map,
                    screenWidth: screenWidth,
                    keyboardType: TextInputType.streetAddress,
                    errorText: controller.addressAreaError.value,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => ModernTextField(
                          labelText: "City",
                          controller: controller.addressCityController,
                          prefixIcon: SolarLinearIcons.buildings2,
                          screenWidth: screenWidth,
                          keyboardType: TextInputType.text,
                          errorText: controller.addressCityError.value,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => ModernTextField(
                          labelText: "State",
                          controller: controller.addressStateController,
                          prefixIcon: SolarLinearIcons.mapPoint,
                          screenWidth: screenWidth,
                          keyboardType: TextInputType.text,
                          errorText: controller.addressStateError.value,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(
                  () => ModernTextField(
                    labelText: "Pincode",
                    controller: controller.addressPincodeController,
                    prefixIcon: SolarLinearIcons.mapPointWave,
                    screenWidth: screenWidth,
                    keyboardType: TextInputType.number,
                    errorText: controller.addressPincodeError.value,
                  ),
                ),
              ],
            )),

        const SizedBox(height: 14),

        Obx(() => _buildEditableSection(
              icon: SolarLinearIcons.phoneCalling,
              title: "Emergency Contacts",
              accentColor: AppColors.rose,
              isEditing: isEmergencyEditing.value,
              onEdit: () => isEmergencyEditing.value = true,
              onCancel: () => isEmergencyEditing.value = false,
              onSave: () {
                controller.saveProfile(fromDashboard: true);
                isEmergencyEditing.value = false;
              },
              readOnlyChildren: [
                _buildInfoRow(
                    SolarLinearIcons.user,
                    "Contact 1 Name",
                    controller.emergencyContactNameController.text.isEmpty
                        ? "Not set"
                        : controller.emergencyContactNameController.text),
                _buildInfoRow(
                    SolarLinearIcons.phone,
                    "Contact 1 Phone",
                    controller.emergencyContactController.text.isEmpty
                        ? "Not set"
                        : controller.emergencyContactController.text),
                _buildInfoRow(
                    SolarLinearIcons.user,
                    "Contact 2 Name",
                    controller.emergencyContactName2Controller.text.isEmpty
                        ? "Not set"
                        : controller.emergencyContactName2Controller.text),
                _buildInfoRow(
                    SolarLinearIcons.phone,
                    "Contact 2 Phone",
                    controller.emergencyContactController2.text.isEmpty
                        ? "Not set"
                        : controller.emergencyContactController2.text),
              ],
              editChildren: [
                ModernTextField(
                  labelText: "Contact 1 Name",
                  controller: controller.emergencyContactNameController,
                  prefixIcon: SolarLinearIcons.user,
                  screenWidth: screenWidth,
                ),
                const SizedBox(height: 12),
                Obx(
                  () => ModernTextField(
                    labelText: "Contact 1 Phone",
                    controller: controller.emergencyContactController,
                    prefixIcon: SolarLinearIcons.phone,
                    screenWidth: screenWidth,
                    keyboardType: TextInputType.phone,
                    errorText: controller.emergencyContactError.value,
                  ),
                ),
                const SizedBox(height: 12),
                ModernTextField(
                  labelText: "Contact 2 Name (Optional)",
                  controller: controller.emergencyContactName2Controller,
                  prefixIcon: SolarLinearIcons.user,
                  screenWidth: screenWidth,
                ),
                const SizedBox(height: 12),
                Obx(
                  () => ModernTextField(
                    labelText: "Contact 2 Phone (Optional)",
                    controller: controller.emergencyContactController2,
                    prefixIcon: SolarLinearIcons.phone,
                    screenWidth: screenWidth,
                    keyboardType: TextInputType.phone,
                    errorText: controller.emergencyContactError2.value,
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
    bool locked = false,
    Color? accentColor,
  }) {
    final accent = accentColor ?? colors.primaryColor;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderColor),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (locked) ...[
                const Spacer(),
                Icon(
                  SolarLinearIcons.lock,
                  size: 14,
                  color: colors.textSecondary.withValues(alpha: 0.5),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildEditableSection({
    required IconData icon,
    required String title,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onCancel,
    required VoidCallback onSave,
    required List<Widget> readOnlyChildren,
    required List<Widget> editChildren,
    Color? accentColor,
  }) {
    final accent = accentColor ?? colors.primaryColor;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderColor),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!isEditing)
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      SolarLinearIcons.pen,
                      size: 16,
                      color: accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isEditing) ...readOnlyChildren else ...editChildren,
          if (isEditing) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textSecondary,
                      side: BorderSide(
                        color: colors.textSecondary.withValues(alpha: 0.2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: colors.textSecondary.withValues(alpha: 0.6)),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
