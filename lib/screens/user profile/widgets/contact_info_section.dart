import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../../controllers/profile_review_controller.dart';
import '../../../core/constants/app_colors.dart';
import 'profile_section_card.dart';

class ContactInfoSection extends StatelessWidget {
  final ProfileReviewController controller;
  const ContactInfoSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      icon: SolarIconsOutline.phone,
      title: 'Contact Information',
      accentColor: AppColors.transfusionAccent,
      locked: true,
      rows: [
        ProfileInfoRow(
          icon: SolarIconsOutline.letter,
          label: 'Email',
          value: controller.emailController.text.trim(),
        ),
        ProfileInfoRow(
          icon: SolarIconsOutline.phone,
          label: 'Phone',
          value: '+91 ${controller.contactController.text.trim()}',
        ),
        ProfileInfoRow(
          icon: SolarIconsOutline.buildings,
          label: 'Blood Bank',
          value: controller.bloodBaankNameController.text,
        ),
      ],
    );
  }
}
