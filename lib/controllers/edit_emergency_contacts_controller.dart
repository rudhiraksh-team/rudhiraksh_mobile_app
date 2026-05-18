import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/utils/validators.dart';
import '../data/models/patient_model.dart';
import '../data/services/error_reporting_service.dart';
import '../data/services/profile_update_service.dart';
import 'global_profile_controller.dart';

/// Owns the emergency-contacts edit form. Lifecycle is scoped to the
/// EditEmergencyContactsScreen route.
class EditEmergencyContactsController extends GetxController {
  // Contact 1
  final name1Controller = TextEditingController();
  final relationship1Controller = TextEditingController();
  final phone1Controller = TextEditingController();

  // Contact 2 (optional)
  final name2Controller = TextEditingController();
  final relationship2Controller = TextEditingController();
  final phone2Controller = TextEditingController();

  final phone1Error = RxnString();
  final phone2Error = RxnString();
  final isLoading = false.obs;

  // Country dial codes (default India). Not persisted by the API yet — the
  // backend strips the prefix and stores only the 10-digit national number.
  String countryCode1 = '+91';
  String countryCode2 = '+91';

  final RxString _phone1Text = ''.obs;
  final RxString _phone2Text = ''.obs;

  Patient? _initialPatient;

  @override
  void onInit() {
    super.onInit();
    _loadFromGlobal();
    _attachDebouncedValidation();
  }

  @override
  void onClose() {
    name1Controller.dispose();
    relationship1Controller.dispose();
    phone1Controller.dispose();
    name2Controller.dispose();
    relationship2Controller.dispose();
    phone2Controller.dispose();
    super.onClose();
  }

  void _loadFromGlobal() {
    final globalProfile = Get.find<GlobalProfileController>();
    if (globalProfile.profileData.isEmpty) return;
    try {
      final patient = Patient.fromJson(
        Map<String, dynamic>.from(globalProfile.profileData),
      );
      _initialPatient = patient;
      name1Controller.text = patient.emergencyContactName;
      relationship1Controller.text = patient.emergencyContactRelationship;
      phone1Controller.text = patient.emergencyContactPhone;
      name2Controller.text = patient.emergencyContactName2 ?? '';
      relationship2Controller.text = patient.emergencyContactRelationship2 ?? '';
      phone2Controller.text = patient.emergencyContactPhone2 ?? '';
    } catch (e) {
      debugPrint('[EDIT-EMERGENCY] Error parsing patient: $e');
    }
  }

  void _attachDebouncedValidation() {
    phone1Controller.addListener(() => _phone1Text.value = phone1Controller.text);
    phone2Controller.addListener(() => _phone2Text.value = phone2Controller.text);

    const debounceTime = Duration(milliseconds: 500);
    debounce(_phone1Text, (_) => _validatePhone1(), time: debounceTime);
    debounce(_phone2Text, (_) => _validatePhone2(), time: debounceTime);
  }

  void _validatePhone1() => phone1Error.value =
      Validators.validateEmergencyContact(phone1Controller.text);
  void _validatePhone2() => phone2Error.value =
      Validators.validateEmergencyContact(phone2Controller.text);

  Future<void> save() async {
    _validatePhone1();
    _validatePhone2();

    if (phone1Error.value != null || phone2Error.value != null) {
      Get.snackbar(
        'Validation Error',
        'Please correct the highlighted fields.',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final patient = _initialPatient;
    if (patient == null) {
      Get.snackbar(
        'Error',
        'Profile not loaded. Please try again.',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final diff = _diff(patient);
    if (diff.isEmpty) {
      Get.back();
      return;
    }

    final globalProfile = Get.find<GlobalProfileController>();
    isLoading.value = true;
    try {
      final result = await ProfileUpdateService.updateProfile(diff);
      isLoading.value = false;

      if (result['success'] == true) {
        final body = result['data'];
        if (body is Map && body['data'] is Map) {
          globalProfile.setProfileData({
            'data': Map<String, dynamic>.from(body['data'] as Map),
          });
        }
        Get.back();
        Get.snackbar(
          'Success',
          'Emergency contacts updated successfully',
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Update failed',
          result['message'] ?? 'Failed to update emergency contacts',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e, s) {
      isLoading.value = false;
      ErrorReportingService.recordError(
        e,
        s,
        tag: 'profile.update.emergency',
        context: {'fields': diff.keys.join(',')},
      );
      Get.snackbar(
        'Error',
        'Unable to update emergency contacts. Please try again.',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Map<String, dynamic> _diff(Patient patient) {
    final diff = <String, dynamic>{};

    if (name1Controller.text.trim() != patient.emergencyContactName.trim()) {
      diff['emergencyContactName'] = name1Controller.text.trim();
    }
    if (relationship1Controller.text.trim() !=
        patient.emergencyContactRelationship.trim()) {
      diff['emergencyContactRelationship'] =
          relationship1Controller.text.trim();
    }
    final phone1 = phone1Controller.text.trim();
    if (phone1 != patient.emergencyContactPhone.trim()) {
      diff['emergencyContactPhone'] =
          phone1.isEmpty ? '' : '$countryCode1$phone1';
    }

    if (name2Controller.text.trim() !=
        (patient.emergencyContactName2 ?? '').trim()) {
      diff['emergencyContactName2'] = name2Controller.text.trim();
    }
    if (relationship2Controller.text.trim() !=
        (patient.emergencyContactRelationship2 ?? '').trim()) {
      diff['emergencyContactRelationship2'] =
          relationship2Controller.text.trim();
    }
    final phone2 = phone2Controller.text.trim();
    if (phone2 != (patient.emergencyContactPhone2 ?? '').trim()) {
      diff['emergencyContactPhone2'] =
          phone2.isEmpty ? '' : '$countryCode2$phone2';
    }

    return diff;
  }
}
