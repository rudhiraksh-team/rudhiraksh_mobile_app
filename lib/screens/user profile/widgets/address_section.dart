import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../../controllers/global_profile_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/helper%20function/navigation_helper.dart';
import '../../../data/models/patient_model.dart';
import 'profile_section_card.dart';

class AddressSection extends StatelessWidget {
  const AddressSection({super.key});

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
        icon: SolarIconsOutline.mapPoint,
        title: 'Address',
        accentColor: AppColors.sky,
        onEdit: NavigationHelper.goToEditAddress,
        rows: [
          ProfileInfoRow(
            icon: SolarIconsOutline.streetsMapPoint,
            label: 'Street',
            value: orNotSet(patient?.addressStreet),
          ),
          ProfileInfoRow(
            icon: SolarIconsOutline.map,
            label: 'Area',
            value: orNotSet(patient?.addressArea),
          ),
          ProfileInfoRow(
            icon: SolarIconsOutline.buildings_2,
            label: 'City',
            value: orNotSet(patient?.addressCity),
          ),
          ProfileInfoRow(
            icon: SolarIconsOutline.mapPoint,
            label: 'State',
            value: orNotSet(patient?.addressState),
          ),
          ProfileInfoRow(
            icon: SolarIconsOutline.mapPointWave,
            label: 'Pincode',
            value: orNotSet(patient?.addressPincode),
          ),
        ],
      );
    });
  }
}
