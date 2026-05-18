import 'package:flutter/material.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';

import '../../../controllers/profile_review_controller.dart';
import '../../../core/constants/app_colors.dart';
import 'profile_section_card.dart';

class PersonalInfoSection extends StatelessWidget {
  final ProfileReviewController controller;
  const PersonalInfoSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      icon: SolarLinearIcons.userCircle,
      title: 'Personal Information',
      accentColor: AppColors.profileAccent,
      locked: true,
      rows: [
        ProfileInfoRow(
          icon: SolarLinearIcons.user,
          label: 'Name',
          value: controller.nameController.text,
        ),
        ProfileInfoRow(
          icon: SolarLinearIcons.calendar,
          label: 'Date of Birth',
          value: controller.dobController.text,
        ),
        ProfileInfoRow(
          icon: SolarLinearIcons.usersGroupRounded,
          label: 'Gender',
          value: controller.genderController.text,
        ),
        ProfileInfoRow(
          icon: SolarLinearIcons.heartPulse,
          label: 'Blood Group',
          value: controller.bloodGroupController.text,
        ),
      ],
    );
  }
}
