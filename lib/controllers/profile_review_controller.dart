import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/blood_bank_model.dart';
import '../data/models/patient_model.dart';
import 'global_profile_controller.dart';

/// Read-only display state for the profile review screen.
///
/// Editing has moved to dedicated routes (EditAddressScreen,
/// EditEmergencyContactsScreen), each backed by its own controller. This
/// controller is responsible only for hydrating the always-visible read-only
/// fields from [GlobalProfileController].
class ProfileReviewController extends GetxController {
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final genderController = TextEditingController();
  final bloodGroupController = TextEditingController();
  final bloodBaankNameController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserDataFromGlobal();
  }

  void _loadUserDataFromGlobal() {
    final globalProfile = Get.find<GlobalProfileController>();

    if (globalProfile.profileData.isNotEmpty) {
      try {
        final patient = Patient.fromJson(
          Map<String, dynamic>.from(globalProfile.profileData),
        );
        nameController.text = patient.fullName;
        dobController.text = patient.dateOfBirth;
        genderController.text = patient.gender;
        bloodGroupController.text = patient.bloodGroup;
        emailController.text = patient.email;
        contactController.text = patient.phoneNumber;
      } catch (e) {
        debugPrint('[PROFILE] Error parsing profile data: $e');
      }
    }

    if (globalProfile.bloodBankData.isNotEmpty) {
      try {
        final bank = BloodBank.fromJson(
          Map<String, dynamic>.from(globalProfile.bloodBankData),
        );
        bloodBaankNameController.text = bank.name;
      } catch (e) {
        debugPrint('[PROFILE] Error parsing blood bank data: $e');
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    dobController.dispose();
    genderController.dispose();
    bloodGroupController.dispose();
    bloodBaankNameController.dispose();
    emailController.dispose();
    contactController.dispose();
    super.onClose();
  }
}
