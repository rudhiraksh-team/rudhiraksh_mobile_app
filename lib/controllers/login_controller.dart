import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rudhirakshapp/controllers/dashboard_controller.dart';
import 'package:rudhirakshapp/controllers/global_profile_controller.dart';
import 'package:rudhirakshapp/controllers/medical_records_controller.dart';
import 'package:rudhirakshapp/data/helper%20function/navigation_helper.dart';
import 'package:rudhirakshapp/data/models/transfusion_list_model.dart';
import 'package:rudhirakshapp/data/services/bloodbank_service.dart';
import 'package:rudhirakshapp/data/services/login_service.dart';
import 'package:rudhirakshapp/data/services/profile_service.dart';
import 'package:rudhirakshapp/data/services/profile_update_service.dart';
import 'package:rudhirakshapp/data/services/push_notification_service.dart';
import 'package:rudhirakshapp/data/services/transfusion_list_service.dart';
import '../core/utils/validators.dart';

class LoginController extends GetxController {
  final globalProfile = Get.find<GlobalProfileController>();
  final basicFormKey = GlobalKey<FormState>();
  Timer? _debounce;

  final userIdController = TextEditingController();
  final passwordController = TextEditingController();

  var userIdError = RxnString();
  var passwordError = RxnString();
  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void validateUserId(String value) {
    userIdError.value = Validators.validateUserIdDynamic(value);
  }

  void validatePassword(String value) {
    passwordError.value = Validators.validatePassword(value);
  }

  void validatePasswordDebounced(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      validatePassword(value);
    });
  }

  void validateUserIdDebounced(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      userIdError.value = Validators.validateUserIdDynamic(value);
    });
  }

  Future<void> login() async {
    validateUserId(userIdController.value.text.trim());
    validatePassword(passwordController.value.text.trim());

    if (userIdError.value != null || passwordError.value != null) return;

    try {
      isLoading.value = true;

      // ---------------- LOGIN via /auth/login ----------------
      final loginData = await LoginService.login(
        userIdController.value.text.trim(),
        passwordController.value.text.trim(),
      );

      if (loginData == null || loginData['success'] == false) {
        final serverMsg = loginData?['error'] ?? 'Login failed';
        Get.snackbar('Error', serverMsg, snackPosition: SnackPosition.BOTTOM);
        isLoading.value = false;
        return;
      }

      // New auth flow: /auth/login returns { data: { accessToken, refreshToken, user } }
      final accessToken = loginData['data']?['accessToken'];

      if (accessToken == null) {
        Get.snackbar('Error', 'Invalid login response', snackPosition: SnackPosition.BOTTOM);
        isLoading.value = false;
        return;
      }

      // Save token locally
      final storage = GetStorage();
      storage.write('token', accessToken);

      // Send existing FCM token to backend
      try {
        final fcmToken = storage.read<String>('fcmToken');
        if (fcmToken != null && fcmToken.isNotEmpty) {
          await ProfileUpdateService.updateProfile({'fcm_token': fcmToken});
          if (kDebugMode) print('FCM token sent on login: $fcmToken');
        }
      } catch (e) {
        if (kDebugMode) print('Failed to send fcm token on login: $e');
      }

      // ---------------- FETCH ME (get user + patient info) ----------------
      final meData = await LoginService.fetchMe(accessToken);
      if (meData != null && meData['data'] != null) {
        final userData = meData['data'];
        final userId = userData['id'];
        final patientId = userData['patientId'];
        storage.write('userId', patientId ?? userId);
        storage.write('supabaseUserId', userId);
        if (userData['bloodBankId'] != null) {
          storage.write('tenantId', userData['bloodBankId']);
        }
      }

      // ---------------- PROFILE ----------------
      final profileData = await ProfileService.fetchProfile(accessToken);
      if (profileData == null) {
        Get.snackbar('Error', 'Profile API failed', snackPosition: SnackPosition.BOTTOM);
        isLoading.value = false;
        return;
      }

      // ---------------- BLOODBANK ----------------
      final bloodBankId = profileData['data']?['patient']?['bloodbank_id'] ??
          profileData['data']?['patient']?['bloodBankId'];
      Map<String, dynamic>? bloodBankData;
      if (bloodBankId != null) {
        bloodBankData = await BloodBankService.fetchBloodBank(bloodBankId, accessToken);
      }

      // ---------------- TRANSFUSION LIST ----------------
      final patientId = storage.read('userId');
      TransfusionResponse? transfusionList;
      if (patientId != null && bloodBankId != null) {
        transfusionList = await TransfusionListService().fetchTransfusions(
          patientId: patientId,
          bloodbankId: bloodBankId,
        );
      }

      // ---------------- SAVE IN GLOBAL CONTROLLER ----------------
      globalProfile.setProfileData(profileData);
      if (bloodBankData != null) {
        globalProfile.setBloodBankData(bloodBankData);
      }
      if (transfusionList != null) {
        globalProfile.setTransfusionList(transfusionList);
      }

      // Save for offline
      storage.write('profileData', profileData);
      if (bloodBankData != null) storage.write('bloodBankData', bloodBankData);
      if (transfusionList != null) {
        storage.write('transfusionList', transfusionList.toJson());
      }

      // ---------------- NAVIGATE ----------------
      isLoading.value = false;

      await PushNotificationService.initializeCore();

      Get.put(DashboardController());
      Get.put(MedicalRecordsController());

      await Get.find<DashboardController>().fetchRecords();
      await Get.find<MedicalRecordsController>().fetchRecords();
      NavigationHelper.goToDashboard();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
