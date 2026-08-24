import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../../controllers/profile_review_controller.dart';
import '../../../core/constants/app_colors.dart';
import 'profile_section_card.dart';

class PersonalInfoSection extends StatelessWidget {
  final ProfileReviewController controller;
  const PersonalInfoSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      icon: SolarIconsOutline.userCircle,
      title: 'Personal Information',
      accentColor: AppColors.profileAccent,
      locked: true,
      rows: [
        ProfileInfoRow(
          icon: SolarIconsOutline.user,
          label: 'Name',
          value: controller.nameController.text,
        ),
        ProfileInfoRow(
          icon: SolarIconsOutline.calendar,
          label: 'Date of Birth',
          value: controller.dobController.text,
        ),
        ProfileInfoRow(
          icon: SolarIconsOutline.usersGroupRounded,
          label: 'Gender',
          value: controller.genderController.text,
        ),
        ProfileInfoRow(
          icon: SolarIconsOutline.heartPulse,
          label: 'Blood Group',
          value: controller.bloodGroupController.text,
        ),
        if (controller.thalassemiaIdController.text.isNotEmpty)
          ProfileInfoRow(
            icon: SolarIconsOutline.card,
            label: 'Thalassemia ID',
            value: controller.thalassemiaIdController.text,
          ),
      ],
    );
  }
}
