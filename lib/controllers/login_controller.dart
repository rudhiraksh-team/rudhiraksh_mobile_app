import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rudhirakshapp/controllers/dashboard_controller.dart';
import 'package:rudhirakshapp/controllers/global_profile_controller.dart';
import 'package:rudhirakshapp/controllers/medical_records_controller.dart';
import 'package:rudhirakshapp/data/helper%20function/navigation_helper.dart';
import 'package:rudhirakshapp/data/models/transfusion_list_model.dart';
import 'package:rudhirakshapp/data/services/bloodbank_service.dart';
import 'package:rudhirakshapp/data/services/error_reporting_service.dart';
import 'package:rudhirakshapp/data/services/login_service.dart';
import 'package:rudhirakshapp/data/services/profile_service.dart';
import 'package:rudhirakshapp/data/services/push_notification_service.dart';
import 'package:rudhirakshapp/data/services/transfusion_list_service.dart';
import 'package:rudhirakshapp/controllers/doctor_dashboard_controller.dart';
import 'package:rudhirakshapp/controllers/notification_controller.dart';
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

  /// Map a service-layer error code to a single-line, user-facing message.
  String _messageFor(LoginResult r, {String fallback = 'Login failed'}) {
    switch (r.errorCode) {
      case LoginErrorCodes.noInternet:
        return 'No internet connection. Please check your network.';
      case LoginErrorCodes.timeout:
        return 'Connection is slow or unstable. Please try again.';
      case LoginErrorCodes.invalidCredentials:
        return r.errorMessage ?? 'Invalid email or password';
      case LoginErrorCodes.serverError:
        return 'Our servers are having trouble. Please try again shortly.';
      case LoginErrorCodes.badResponse:
        return 'Unexpected response from server. Please try again.';
      default:
        return r.errorMessage ?? fallback;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Login',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  Future<bool> _hasConnectivity() async {
    try {
      final result = await Connectivity()
          .checkConnectivity()
          .timeout(const Duration(seconds: 3));
      // connectivity_plus 7.x returns List<ConnectivityResult>.
      // Anything other than only-`none` counts as "has a network".
      return result.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      // If the check itself fails, don't block the user — let the request try.
      return true;
    }
  }

  Future<void> login() async {
    validateUserId(userIdController.value.text.trim());
    validatePassword(passwordController.value.text.trim());

    if (userIdError.value != null || passwordError.value != null) return;

    isLoading.value = true;
    try {
      // Fail-fast offline check so the user isn't staring at a 20s spinner.
      if (!await _hasConnectivity()) {
        _showError('No internet connection. Please check your network.');
        return;
      }

      debugPrint('[LOGIN] Starting login for: ${userIdController.value.text.trim()}');
      await ErrorReportingService.log('login attempt started');

      // ---------------- /auth/login ----------------
      final loginRes = await LoginService.login(
        userIdController.value.text.trim(),
        passwordController.value.text.trim(),
      );

      if (!loginRes.success) {
        debugPrint('[LOGIN] Login failed: ${loginRes.errorCode} ${loginRes.errorMessage}');
        _showError(_messageFor(loginRes));
        return;
      }

      final loginData = loginRes.data!;
      final accessToken = loginData['data']?['accessToken'];
      if (accessToken == null) {
        await ErrorReportingService.recordError(
          StateError('Missing accessToken in login response'),
          StackTrace.current,
          tag: 'login.shape',
          context: {'has_data': loginData['data'] != null},
        );
        _showError('Invalid login response. Please try again.');
        return;
      }

      final storage = GetStorage();
      storage.write('token', accessToken);

      // ---------------- /auth/me ----------------
      var meRes = await LoginService.fetchMe(accessToken);

      // 404 -> attempt setup-patient-profile then retry /auth/me.
      if (!meRes.success && meRes.statusCode == 404) {
        final email = userIdController.value.text.trim();
        final setupRes = await LoginService.setupPatientProfile(
          accessToken,
          name: email.split('@').first,
        );
        if (setupRes.success) {
          meRes = await LoginService.fetchMe(accessToken);
        } else {
          await ErrorReportingService.recordError(
            StateError('setup-patient-profile failed'),
            StackTrace.current,
            tag: 'login.setup',
            context: {
              'code': setupRes.errorCode ?? 'unknown',
              if (setupRes.statusCode != null) 'status': setupRes.statusCode!,
            },
          );
          _showError('Account setup failed. Please contact support.');
          return;
        }
      }

      if (!meRes.success) {
        _showError(_messageFor(meRes, fallback: 'Failed to load your profile'));
        return;
      }

      final meData = meRes.data!;
      final userData = meData['data'] as Map<String, dynamic>?;
      if (userData == null) {
        await ErrorReportingService.recordError(
          StateError('Missing data field in /auth/me response'),
          StackTrace.current,
          tag: 'login.shape',
        );
        _showError('Unexpected profile response. Please try again.');
        return;
      }

      final userId = userData['id'];
      final patientId = userData['patientId'];
      final authId = userData['authId'];
      storage.write('userId', patientId ?? userId);
      storage.write('dbUserId', userId);
      storage.write('supabaseUserId', authId ?? userId);
      if (patientId != null) storage.write('patientId', patientId);
      if (userData['bloodBankId'] != null) {
        storage.write('tenantId', userData['bloodBankId']);
        storage.write('bloodBankId', userData['bloodBankId']);
      }

      // Tag subsequent crash reports with the user.
      if (userId != null) {
        await ErrorReportingService.setUserId(userId.toString());
      }

      // FCM token sync is best-effort — never block login on it. ensureTokenSynced
      // closes the cold-start race: if the cache is empty (e.g. fresh install or
      // slow Firebase init) it will fetch a token directly with a short timeout
      // before POSTing, so the patient row gets a valid token even on first run.
      try {
        await PushNotificationService.ensureTokenSynced();
      } catch (e, s) {
        await ErrorReportingService.recordError(e, s, tag: 'login.fcm');
      }

      // ---------------- ROLE-BASED FETCH ----------------
      final userRole =
          meData['data']?['role']?['value'] ?? meData['data']?['role'];
      final isPatient = userRole == 'patient';
      storage.write('userRole', userRole ?? 'patient');

      Map<String, dynamic>? profileData;
      Map<String, dynamic>? bloodBankData;
      TransfusionResponse? transfusionList;

      if (isPatient) {
        try {
          profileData = await ProfileService.fetchProfile(accessToken);
        } catch (e, s) {
          await ErrorReportingService.recordError(e, s, tag: 'login.profile');
        }

        if (profileData == null) {
          _showError('Could not load your profile. Please try again.');
          return;
        }

        final bloodBankId = profileData['data']?['bloodBankId'] ??
            profileData['data']?['bloodbank_id'] ??
            profileData['data']?['bloodBank']?['id'] ??
            profileData['data']?['patient']?['bloodBankId'] ??
            profileData['data']?['patient']?['bloodbank_id'];

        if (bloodBankId != null) {
          try {
            bloodBankData =
                await BloodBankService.fetchBloodBank(bloodBankId, accessToken);
          } catch (e, s) {
            await ErrorReportingService.recordError(e, s,
                tag: 'login.bloodbank');
          }
        }

        // Fall back to embedded bloodBank from profile if separate fetch failed.
        if (bloodBankData == null) {
          final embeddedBank = profileData['data']?['bloodBank'];
          if (embeddedBank != null) {
            bloodBankData = {'success': true, 'data': embeddedBank};
          }
        }

        if (bloodBankId != null && storage.read('bloodBankId') == null) {
          storage.write('bloodBankId', bloodBankId);
        }

        final patientIdLocal = storage.read('userId');
        if (patientIdLocal != null && bloodBankId != null) {
          try {
            transfusionList = await TransfusionListService().fetchTransfusions(
              patientId: patientIdLocal,
              bloodbankId: bloodBankId,
            );
          } catch (e, s) {
            await ErrorReportingService.recordError(e, s,
                tag: 'login.transfusions');
          }
        }
      }

      // ---------------- SAVE ----------------
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
      try {
        await PushNotificationService.initializeCore();
      } catch (e, s) {
        await ErrorReportingService.recordError(e, s, tag: 'login.push_init');
      }

      if (userRole == 'doctor') {
        Get.put(DoctorDashboardController());
        Get.put(NotificationController());
        NavigationHelper.goToDoctorDashboard();
      } else {
        Get.put(DashboardController());
        Get.put(MedicalRecordsController());
        try {
          await Get.find<DashboardController>().fetchRecords();
          await Get.find<MedicalRecordsController>().fetchRecords();
        } catch (e, s) {
          await ErrorReportingService.recordError(e, s,
              tag: 'login.dashboard_prefetch');
        }
        NavigationHelper.goToDashboard();
      }
    } catch (e, stackTrace) {
      await ErrorReportingService.recordError(e, stackTrace, tag: 'login.unhandled');
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
