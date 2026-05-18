import 'package:flutter/material.dart';

import '../../../controllers/profile_review_controller.dart';
import 'address_section.dart';
import 'contact_info_section.dart';
import 'emergency_contacts_section.dart';
import 'personal_info_section.dart';

/// Composes the four profile sections. Editing the address and emergency
/// contacts now lives on dedicated routes; this card is read-only.
class ProfileGlassCard extends StatelessWidget {
  final ProfileReviewController controller;

  const ProfileGlassCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PersonalInfoSection(controller: controller),
        const SizedBox(height: 14),
        ContactInfoSection(controller: controller),
        const SizedBox(height: 14),
        const AddressSection(),
        const SizedBox(height: 14),
        const EmergencyContactsSection(),
      ],
    );
  }
}
