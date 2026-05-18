import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/utils/validators.dart';
import '../data/models/patient_model.dart';
import '../data/services/error_reporting_service.dart';
import '../data/services/profile_update_service.dart';
import 'global_profile_controller.dart';

/// Owns the address-edit form. Lifecycle is scoped to the EditAddressScreen
/// route, so it is auto-created on push and disposed on pop.
class EditAddressController extends GetxController {
  final streetController = TextEditingController();
  final areaController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  final streetError = RxnString();
  final areaError = RxnString();
  final cityError = RxnString();
  final stateError = RxnString();
  final pincodeError = RxnString();

  final isLoading = false.obs;

  final RxString _streetText = ''.obs;
  final RxString _areaText = ''.obs;
  final RxString _cityText = ''.obs;
  final RxString _stateText = ''.obs;
  final RxString _pincodeText = ''.obs;

  Patient? _initialPatient;

  @override
  void onInit() {
    super.onInit();
    _loadFromGlobal();
    _attachDebouncedValidation();
  }

  @override
  void onClose() {
    streetController.dispose();
    areaController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
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
      streetController.text = patient.addressStreet;
      areaController.text = patient.addressArea;
      cityController.text = patient.addressCity;
      stateController.text = patient.addressState;
      pincodeController.text = patient.addressPincode;
    } catch (e) {
      debugPrint('[EDIT-ADDRESS] Error parsing patient: $e');
    }
  }

  void _attachDebouncedValidation() {
    streetController.addListener(() => _streetText.value = streetController.text);
    areaController.addListener(() => _areaText.value = areaController.text);
    cityController.addListener(() => _cityText.value = cityController.text);
    stateController.addListener(() => _stateText.value = stateController.text);
    pincodeController
        .addListener(() => _pincodeText.value = pincodeController.text);

    const debounceTime = Duration(milliseconds: 500);
    debounce(_streetText, (_) => _validateStreet(), time: debounceTime);
    debounce(_areaText, (_) => _validateArea(), time: debounceTime);
    debounce(_cityText, (_) => _validateCity(), time: debounceTime);
    debounce(_stateText, (_) => _validateState(), time: debounceTime);
    debounce(_pincodeText, (_) => _validatePincode(), time: debounceTime);
  }

  void _validateStreet() =>
      streetError.value = Validators.validateStreet(streetController.text);
  void _validateArea() =>
      areaError.value = Validators.validateRequired(areaController.text);
  void _validateCity() =>
      cityError.value = Validators.validateCity(cityController.text);
  void _validateState() =>
      stateError.value = Validators.validateState(stateController.text);
  void _validatePincode() =>
      pincodeError.value = Validators.validatePincode(pincodeController.text);

  /// Validate all fields, diff against the initial patient, persist via API,
  /// and pop the route on success.
  Future<void> save() async {
    _validateStreet();
    _validateArea();
    _validateCity();
    _validateState();
    _validatePincode();

    final hasError = streetError.value != null ||
        areaError.value != null ||
        cityError.value != null ||
        stateError.value != null ||
        pincodeError.value != null;
    if (hasError) {
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
          'Address updated successfully',
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Update failed',
          result['message'] ?? 'Failed to update address',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e, s) {
      isLoading.value = false;
      ErrorReportingService.recordError(
        e,
        s,
        tag: 'profile.update.address',
        context: {'fields': diff.keys.join(',')},
      );
      Get.snackbar(
        'Error',
        'Unable to update address. Please try again.',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Map<String, dynamic> _diff(Patient patient) {
    final diff = <String, dynamic>{};
    if (streetController.text.trim() != patient.addressStreet.trim()) {
      diff['street'] = streetController.text.trim();
    }
    if (areaController.text.trim() != patient.addressArea.trim()) {
      diff['address'] = areaController.text.trim();
    }
    if (cityController.text.trim() != patient.addressCity.trim()) {
      diff['city'] = cityController.text.trim();
    }
    if (stateController.text.trim() != patient.addressState.trim()) {
      diff['state'] = stateController.text.trim();
    }
    if (pincodeController.text.trim() != patient.addressPincode.trim()) {
      diff['pincode'] = pincodeController.text.trim();
    }
    return diff;
  }
}
