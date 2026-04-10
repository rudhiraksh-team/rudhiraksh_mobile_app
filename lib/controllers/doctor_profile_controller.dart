import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rudhirakshapp/data/services/doctor_service.dart';

class DoctorProfileController extends GetxController {
  final storage = GetStorage();

  final RxMap<String, dynamic> profileData = <String, dynamic>{}.obs;
  var isLoading = false.obs;

  // Editable fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String get doctorName => profileData['name'] ?? '';
  String get doctorEmail => profileData['email'] ?? '';
  String get doctorPhone => profileData['phone'] ?? '';
  String get bloodBankName => profileData['bloodBank']?['name'] ?? '';
  String get bloodBankLogo => profileData['bloodBank']?['logo_url'] ?? profileData['bloodBank']?['logoUrl'] ?? '';
  String get roleName => profileData['role']?['label'] ?? profileData['role']?['value'] ?? 'Doctor';

  String get initials {
    final name = doctorName;
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  void onInit() {
    super.onInit();
    _loadCached();
    fetchProfile();
  }

  void _loadCached() {
    final cached = storage.read('doctorProfileData');
    if (cached != null) {
      profileData.assignAll(Map<String, dynamic>.from(cached));
      _fillControllers();
    }
  }

  void _fillControllers() {
    nameController.text = doctorName;
    emailController.text = doctorEmail;
    phoneController.text = doctorPhone;
  }

  void resetControllers() {
    _fillControllers();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await DoctorService.fetchProfile();
      if (response != null && response['success'] == true && response['data'] != null) {
        final data = Map<String, dynamic>.from(response['data']);
        profileData.assignAll(data);
        storage.write('doctorProfileData', data);
        _fillControllers();
      }
    } catch (e) {
      debugPrint('fetchDoctorProfile error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    final changedFields = <String, dynamic>{};

    if (nameController.text.trim() != doctorName) {
      changedFields['name'] = nameController.text.trim();
    }
    if (phoneController.text.trim() != doctorPhone) {
      changedFields['phone'] = phoneController.text.trim();
    }

    if (changedFields.isEmpty) {
      Get.snackbar('No changes', 'Nothing to update', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      final result = await DoctorService.updateProfile(changedFields);
      if (result['success'] == true) {
        await fetchProfile();
        Get.snackbar('Success', 'Profile updated', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', result['message'] ?? 'Update failed',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Unable to update profile', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
