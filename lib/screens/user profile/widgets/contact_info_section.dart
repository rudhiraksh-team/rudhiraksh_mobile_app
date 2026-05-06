import 'package:flutter/material.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';

import '../../../controllers/profile_review_controller.dart';
import '../../../core/constants/app_colors.dart';
import 'profile_section_card.dart';

class ContactInfoSection extends StatelessWidget {
  final ProfileReviewController controller;
  const ContactInfoSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      icon: SolarLinearIcons.phone,
      title: 'Contact Information',
      accentColor: AppColors.transfusionAccent,
      locked: true,
      rows: [
        ProfileInfoRow(
          icon: SolarLinearIcons.letter,
          label: 'Email',
          value: controller.emailController.text.trim(),
        ),
        ProfileInfoRow(
          icon: SolarLinearIcons.phone,
          label: 'Phone',
          value: '+91 ${controller.contactController.text.trim()}',
        ),
        ProfileInfoRow(
          icon: SolarLinearIcons.buildings,
          label: 'Blood Bank',
          value: controller.bloodBaankNameController.text,
        ),
      ],
    );
  }
}
