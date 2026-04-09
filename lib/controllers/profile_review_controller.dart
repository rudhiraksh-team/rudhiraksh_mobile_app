import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rudhirakshapp/controllers/dashboard_controller.dart';
import 'package:rudhirakshapp/data/helper%20function/navigation_helper.dart';
import 'package:rudhirakshapp/data/models/blood_bank_model.dart';
import 'package:rudhirakshapp/data/models/patient_model.dart';
import 'package:rudhirakshapp/data/services/profile_update_service.dart';
import '../core/utils/validators.dart';
import 'global_profile_controller.dart';

class ProfileReviewController extends GetxController {
  // Text controllers
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final genderController = TextEditingController();
  final bloodGroupController = TextEditingController();
  final bloodBaankNameController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();

  final addressStreetController = TextEditingController();
  final addressAreaController = TextEditingController();
  final addressCityController = TextEditingController();
  final addressStateController = TextEditingController();
  final addressPincodeController = TextEditingController();

  final emergencyContactNameController = TextEditingController();
  final emergencyContactController = TextEditingController();
  final emergencyContactName2Controller = TextEditingController();
  final emergencyContactController2 = TextEditingController();

  // Error states (reactive)
  var addressStreetError = RxnString();
  var addressAreaError = RxnString();
  var addressCityError = RxnString();
  var addressStateError = RxnString();
  var addressPincodeError = RxnString();
  var emergencyContactError = RxnString();
  var emergencyContactError2 = RxnString();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load user data
    _loadUserDataFromGlobal();

    // Add validation listeners
    _addValidationListeners();
  }

  //Load from global ProfileController instead of arguments
  void _loadUserDataFromGlobal() {
    final globalProfile = Get.find<GlobalProfileController>();

    if (globalProfile.profileData.isNotEmpty) {
      try {
        //parse profile data
        final patient = Patient.fromJson(
          Map<String, dynamic>.from(globalProfile.profileData),
        );

        // Fill text controllers
        nameController.text = patient.fullName;
        dobController.text = patient.dateOfBirth;
        genderController.text = patient.gender;
        bloodGroupController.text = patient.bloodGroup;
        emailController.text = patient.email;
        addressStreetController.text = patient.addressStreet;
        addressAreaController.text = patient.addressArea;
        addressCityController.text = patient.addressCity;
        addressStateController.text = patient.addressState;
        addressPincodeController.text = patient.addressPincode;
        contactController.text = patient.phoneNumber;
        emergencyContactNameController.text = patient.emergencyContactName;
        emergencyContactController.text = patient.emergencyContactPhone;
        emergencyContactName2Controller.text = patient.emergencyContactName2 ?? '';
        emergencyContactController2.text = patient.emergencyContactPhone2 ?? '';
      } catch (e) {
        debugPrint('[PROFILE] Error parsing profile data: $e');
      }
    }
    // Fill blood bank if available
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

  // Rx variables for debouncing text changes
  final RxString addressStreetText = ''.obs;
  final RxString addressAreaText = ''.obs;
  final RxString addressCityText = ''.obs;
  final RxString addressStateText = ''.obs;
  final RxString addressPincodeText = ''.obs;
  final RxString emergencyContactText = ''.obs;
  final RxString emergencyContactText2 = ''.obs;

  // Add validation listeners
  void _addValidationListeners() {
    addressStreetController.addListener(() {
      addressStreetText.value = addressStreetController.text;
    });
    addressAreaController.addListener(() {
      addressAreaText.value = addressAreaController.text;
    });
    addressCityController.addListener(() {
      addressCityText.value = addressCityController.text;
    });
    addressStateController.addListener(() {
      addressStateText.value = addressStateController.text;
    });
    addressPincodeController.addListener(() {
      addressPincodeText.value = addressPincodeController.text;
    });
    emergencyContactController.addListener(() {
      emergencyContactText.value = emergencyContactController.text;
    });
    emergencyContactController2.addListener(() {
      emergencyContactText2.value = emergencyContactController2.text;
    });

    // Debounce validation calls
    debounce(
      addressStreetText,
      (_) => validateAddressStreet(),
      time: const Duration(milliseconds: 500),
    );
    debounce(
      addressAreaText,
      (_) => validateAddressArea(),
      time: const Duration(milliseconds: 500),
    );
    debounce(
      addressCityText,
      (_) => validateAddressCity(),
      time: const Duration(milliseconds: 500),
    );
    debounce(
      addressStateText,
      (_) => validateAddressState(),
      time: const Duration(milliseconds: 500),
    );
    debounce(
      addressPincodeText,
      (_) => validateAddressPincode(),
      time: const Duration(milliseconds: 500),
    );
    debounce(
      emergencyContactText,
      (_) => validateEmergencyContact(),
      time: const Duration(milliseconds: 500),
    );
    debounce(
      emergencyContactText2,
      (_) => validateEmergencyContact2(),
      time: const Duration(milliseconds: 500),
    );
  }

  // Street Validation method
  void validateAddressStreet() {
    addressStreetError.value = Validators.validateStreet(
      addressStreetController.text,
    );
  }

  // Area Validation method
  void validateAddressArea() {
    addressAreaError.value = Validators.validateRequired(
      addressAreaController.text,
    );
  }

  // City Validation method
  void validateAddressCity() {
    addressCityError.value = Validators.validateCity(
      addressCityController.text,
    );
  }

  // State Validation method
  void validateAddressState() {
    addressStateError.value = Validators.validateState(
      addressStateController.text,
    );
  }

  // Pincode Validation method
  void validateAddressPincode() {
    addressPincodeError.value = Validators.validatePincode(
      addressPincodeController.text,
    );
  }

  // Emergency Contact 1 Validation method
  void validateEmergencyContact() {
    emergencyContactError.value = Validators.validateEmergencyContact(
      emergencyContactController.text,
    );
  }

  // Emergency Contact 2 Validation method
  void validateEmergencyContact2() {
    emergencyContactError2.value = Validators.validateEmergencyContact(
      emergencyContactController2.text,
    );
  }

  // Change signature to accept optional flag
  void saveProfile({bool fromDashboard = false}) async {
    //  Run all validations
    validateAddressStreet();
    validateAddressArea();
    validateAddressCity();
    validateAddressState();
    validateAddressPincode();
    validateEmergencyContact();
    validateEmergencyContact2();

    final globalProfile = Get.find<GlobalProfileController>();
    final box = GetStorage();

    // Parse existing patient data
    Patient? patient =
        globalProfile.profileData.isNotEmpty
            ? Patient.fromJson(
              Map<String, dynamic>.from(globalProfile.profileData),
            )
            : null;

    // Check validation errors
    final hasValidationError =
        addressStreetError.value != null ||
        addressAreaError.value != null ||
        addressCityError.value != null ||
        addressStateError.value != null ||
        addressPincodeError.value != null ||
        emergencyContactError.value != null ||
        emergencyContactError2.value != null;

    // If validation errors, show snackbar and return
    if (hasValidationError) {
      Get.snackbar(
        'Validation Error',
        'Please correct the errors before saving.',
        duration: Duration(seconds: 2),
      );
      return;
    } else if (patient != null) {
      //Compare editable fields

      final changedFields = <String, dynamic>{};

      // Use camelCase keys to match backend Zod validation schema
      if (addressStreetController.text.trim() != patient.addressStreet.trim()) {
        changedFields['street'] = addressStreetController.text.trim();
      }
      if (addressAreaController.text.trim() != (patient.addressArea).trim()) {
        changedFields['address'] = addressAreaController.text.trim();
      }
      if (addressPincodeController.text.trim() !=
          (patient.addressPincode).trim()) {
        changedFields['pincode'] = addressPincodeController.text.trim();
      }
      if (addressCityController.text.trim() != patient.addressCity.trim()) {
        changedFields['city'] = addressCityController.text.trim();
      }
      if (addressStateController.text.trim() != patient.addressState.trim()) {
        changedFields['state'] = addressStateController.text.trim();
      }
      if (emergencyContactNameController.text.trim() !=
          patient.emergencyContactName.trim()) {
        changedFields['emergencyContactName'] =
            emergencyContactNameController.text.trim();
      }
      if (emergencyContactController.text.trim() !=
          patient.emergencyContactPhone.trim()) {
        changedFields['emergencyContactPhone'] =
            emergencyContactController.text.trim();
      }
      if (emergencyContactName2Controller.text.trim() !=
          (patient.emergencyContactName2 ?? '').trim()) {
        changedFields['emergencyContactName2'] =
            emergencyContactName2Controller.text.trim();
      }
      if (emergencyContactController2.text.trim() !=
          (patient.emergencyContactPhone2 ?? '').trim()) {
        changedFields['emergencyContactPhone2'] =
            emergencyContactController2.text.trim();
      }

      // If opened from dashboard and there are NO changes -> go back to dashboard (home)
      if (fromDashboard && changedFields.isEmpty) {
        // Ensure dashboard home tab selected if controller exists
        if (Get.isRegistered<DashboardController>()) {
          final dashboardController = Get.find<DashboardController>();
          dashboardController.bottomNavIndex.value = 0;
        }
        NavigationHelper.goToDashboard();
        return;
      }

      // Update profile if there are changes
      if (changedFields.isNotEmpty) {
        try {
          isLoading.value = true;
          final result = await ProfileUpdateService.updateProfile(
            changedFields,
          );
          isLoading.value = false;

          if (result['success'] == true) {
            // Merge changes into globalProfile
            final updatedMap = Map<String, dynamic>.from(
              globalProfile.profileData,
            );
            updatedMap.addAll(changedFields);
            globalProfile.profileData = updatedMap.obs;

            // Save locally
            box.write('profile', updatedMap);

            Get.snackbar(
              'Success',
              'Profile updated successfully',
              duration: Duration(seconds: 2),
            );

            // If opened from dashboard, stay on the same profile screen (no navigation)
            if (fromDashboard) {
              // Optionally update controller/UI states if needed (we already updated globalProfile)
              return;
            } else {
              // If not from dashboard, navigate to dashboard as before
              if (Get.isRegistered<DashboardController>()) {
                final dashboardController = Get.find<DashboardController>();
                dashboardController.bottomNavIndex.value = 0;
              }
              NavigationHelper.goToDashboard();
              return;
            }
          } else {
            final msg = result['message'] ?? 'Failed to update profile';
            Get.snackbar('Update failed', msg, duration: Duration(seconds: 2));
          }
        } catch (e) {
          isLoading.value = false;
          Get.snackbar(
            'Error',
            'Unable to update profile. Please try again.',
            duration: Duration(seconds: 2),
          );
        }
      } else {
        // Navigate to dashboard (same as previous behavior)
        if (Get.isRegistered<DashboardController>()) {
          final dashboardController = Get.find<DashboardController>();
          dashboardController.bottomNavIndex.value = 0;
        }
        NavigationHelper.goToDashboard();
      }
    } else {
      // patient is null — fallback navigation to dashboard
      if (Get.isRegistered<DashboardController>()) {
        final dashboardController = Get.find<DashboardController>();
        dashboardController.bottomNavIndex.value = 0;
      }
      NavigationHelper.goToDashboard();
    }
  }
}
