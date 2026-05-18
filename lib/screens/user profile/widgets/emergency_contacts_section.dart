import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';

import '../../../controllers/global_profile_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/helper%20function/navigation_helper.dart';
import '../../../data/models/patient_model.dart';
import 'profile_section_card.dart';

class EmergencyContactsSection extends StatelessWidget {
  const EmergencyContactsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final globalProfile = Get.find<GlobalProfileController>();
      Patient? patient;
      try {
        if (globalProfile.profileData.isNotEmpty) {
          patient = Patient.fromJson(
            Map<String, dynamic>.from(globalProfile.profileData),
          );
        }
      } catch (_) {}

      String orNotSet(String? v) => (v == null || v.trim().isEmpty) ? 'Not set' : v;

      return ProfileSectionCard(
        icon: SolarLinearIcons.phoneCalling,
        title: 'Emergency Contacts',
        accentColor: AppColors.rose,
        onEdit: NavigationHelper.goToEditEmergencyContacts,
        rows: [
          ProfileInfoRow(
            icon: SolarLinearIcons.user,
            label: 'Contact 1 Name',
            value: orNotSet(patient?.emergencyContactName),
          ),
          ProfileInfoRow(
            icon: SolarLinearIcons.usersGroupRounded,
            label: 'Contact 1 Relation',
            value: orNotSet(patient?.emergencyContactRelationship),
          ),
          ProfileInfoRow(
            icon: SolarLinearIcons.phone,
            label: 'Contact 1 Phone',
            value: orNotSet(patient?.emergencyContactPhone),
          ),
          ProfileInfoRow(
            icon: SolarLinearIcons.user,
            label: 'Contact 2 Name',
            value: orNotSet(patient?.emergencyContactName2),
          ),
          ProfileInfoRow(
            icon: SolarLinearIcons.usersGroupRounded,
            label: 'Contact 2 Relation',
            value: orNotSet(patient?.emergencyContactRelationship2),
          ),
          ProfileInfoRow(
            icon: SolarLinearIcons.phone,
            label: 'Contact 2 Phone',
            value: orNotSet(patient?.emergencyContactPhone2),
          ),
        ],
      );
    });
  }
}
