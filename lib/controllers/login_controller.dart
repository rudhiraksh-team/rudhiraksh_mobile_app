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
      debugPrint('[LOGIN] Starting login for: ${userIdController.value.text.trim()}');

      // ---------------- LOGIN via /auth/login ----------------
      final loginData = await LoginService.login(
        userIdController.value.text.trim(),
        passwordController.value.text.trim(),
      );

      debugPrint('[LOGIN] /auth/login response: $loginData');

      if (loginData == null || loginData['success'] == false) {
        final serverMsg = loginData?['error'] ?? 'Login failed';
        debugPrint('[LOGIN] Login failed: $serverMsg');
        Get.snackbar('Error', serverMsg, snackPosition: SnackPosition.BOTTOM);
        isLoading.value = false;
        return;
      }

      // New auth flow: /auth/login returns { data: { accessToken, refreshToken, user } }
      final accessToken = loginData['data']?['accessToken'];

      if (accessToken == null) {
        debugPrint('[LOGIN] No accessToken in response. Full response: $loginData');
        Get.snackbar('Error', 'Invalid login response', snackPosition: SnackPosition.BOTTOM);
        isLoading.value = false;
        return;
      }

      debugPrint('[LOGIN] Got accessToken: ${accessToken.substring(0, 20)}...');

      // Save token locally
      final storage = GetStorage();
      storage.write('token', accessToken);

      // ---------------- FETCH ME (get user + patient info) ----------------
      debugPrint('[LOGIN] Fetching /auth/me...');
      final meData = await LoginService.fetchMe(accessToken);
      debugPrint('[LOGIN] /auth/me response: $meData');

      if (meData != null && meData['data'] != null) {
        final userData = meData['data'];
        final userId = userData['id'];
        final patientId = userData['patientId'];
        final authId = userData['authId'];
        debugPrint('[LOGIN] userId=$userId, patientId=$patientId, authId=$authId');
        storage.write('userId', patientId ?? userId);
        storage.write('dbUserId', userId);
        storage.write('supabaseUserId', authId ?? userId);
        if (userData['bloodBankId'] != null) {
          storage.write('tenantId', userData['bloodBankId']);
          debugPrint('[LOGIN] tenantId=${userData['bloodBankId']}');
        }
      } else {
        debugPrint('[LOGIN] WARNING: /auth/me returned null or no data');
      }

      // Send existing FCM token to backend
      try {
        final fcmToken = storage.read<String>('fcmToken');
        if (fcmToken != null && fcmToken.isNotEmpty) {
          debugPrint('[LOGIN] Sending FCM token to backend...');
          await ProfileUpdateService.updateFcmToken(fcmToken);
          debugPrint('[LOGIN] FCM token sent successfully');
        }
      } catch (e) {
        debugPrint('[LOGIN] Failed to send FCM token: $e');
      }

      // ---------------- ROLE-BASED DATA FETCH ----------------
      final userRole = meData?['data']?['role']?['value'] ?? meData?['data']?['role'];
      final isPatient = userRole == 'patient';
      storage.write('userRole', userRole ?? 'patient');
      debugPrint('[LOGIN] userRole=$userRole, isPatient=$isPatient');

      Map<String, dynamic>? profileData;
      Map<String, dynamic>? bloodBankData;
      TransfusionResponse? transfusionList;

      if (isPatient) {
        // Fetch patient-specific data
        debugPrint('[LOGIN] Fetching patient profile...');
        profileData = await ProfileService.fetchProfile(accessToken);
        debugPrint('[LOGIN] Profile response: ${profileData != null ? 'OK' : 'NULL'}');

        if (profileData == null) {
          debugPrint('[LOGIN] Profile API failed - stopping login');
          Get.snackbar('Error', 'Profile API failed', snackPosition: SnackPosition.BOTTOM);
          isLoading.value = false;
          return;
        }

        final bloodBankId = profileData['data']?['patient']?['bloodbank_id'] ??
            profileData['data']?['patient']?['bloodBankId'] ??
            profileData['data']?['bloodbank_id'] ??
            profileData['data']?['bloodBankId'] ??
            profileData['data']?['bloodBank']?['id'];
        debugPrint('[LOGIN] bloodBankId from profile: $bloodBankId');

        if (bloodBankId != null) {
          bloodBankData = await BloodBankService.fetchBloodBank(bloodBankId, accessToken);
          debugPrint('[LOGIN] BloodBank API response: ${bloodBankData != null ? 'OK' : 'NULL'}');
        }

        // Fallback: use bloodBank from profile response if separate fetch failed
        if (bloodBankData == null) {
          final embeddedBank = profileData['data']?['bloodBank'] ?? profileData['data']?['patient']?['bloodBank'];
          if (embeddedBank != null) {
            bloodBankData = {'success': true, 'data': embeddedBank};
            debugPrint('[LOGIN] Using embedded bloodBank from profile response');
          }
        }

        final patientId = storage.read('userId');
        if (patientId != null && bloodBankId != null) {
          debugPrint('[LOGIN] Fetching transfusions for patient=$patientId, bank=$bloodBankId');
          transfusionList = await TransfusionListService().fetchTransfusions(
            patientId: patientId,
            bloodbankId: bloodBankId,
          );
          debugPrint('[LOGIN] Transfusions: ${transfusionList != null ? 'OK' : 'NULL'}');
        }
      } else {
        debugPrint('[LOGIN] Non-patient role ($userRole) - skipping patient-specific fetches');
      }

      // ---------------- SAVE IN GLOBAL CONTROLLER ----------------
      if (profileData != null) {
        globalProfile.setProfileData(profileData);
        storage.write('profileData', profileData);
      }
      if (bloodBankData != null) {
        globalProfile.setBloodBankData(bloodBankData);
        storage.write('bloodBankData', bloodBankData);
      }
      if (transfusionList != null) {
        globalProfile.setTransfusionList(transfusionList);
        storage.write('transfusionList', transfusionList.toJson());
      }

      // ---------------- NAVIGATE ----------------
      isLoading.value = false;
      debugPrint('[LOGIN] Initializing push notifications...');
      await PushNotificationService.initializeCore();

      Get.put(DashboardController());
      Get.put(MedicalRecordsController());

      debugPrint('[LOGIN] Fetching dashboard & medical records...');
      await Get.find<DashboardController>().fetchRecords();
      await Get.find<MedicalRecordsController>().fetchRecords();
      debugPrint('[LOGIN] Login complete - navigating to dashboard');
      NavigationHelper.goToDashboard();
    } catch (e, stackTrace) {
      isLoading.value = false;
      debugPrint('[LOGIN] EXCEPTION: $e');
      debugPrint('[LOGIN] STACKTRACE: $stackTrace');
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
