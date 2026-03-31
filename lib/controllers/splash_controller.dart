import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rudhirakshapp/controllers/dashboard_controller.dart';
import 'package:rudhirakshapp/controllers/medical_records_controller.dart';
import 'package:rudhirakshapp/data/models/transfusion_list_model.dart';
import 'package:rudhirakshapp/data/services/bloodbank_service.dart';
import 'package:rudhirakshapp/data/services/profile_service.dart';
import 'package:rudhirakshapp/data/services/transfusion_list_service.dart';
import 'package:rudhirakshapp/routes/app_routes.dart';
import 'package:rudhirakshapp/screens/Login/login_screen.dart';
import 'package:rudhirakshapp/controllers/global_profile_controller.dart';

class SplashController extends GetxController {
  final storage = GetStorage();
  final globalProfile = Get.put(GlobalProfileController());

  // Timeout duration for API calls
  final Duration apiTimeout = const Duration(seconds: 7);

  @override
  void onInit() {
    super.onInit();

    // App initialization
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    String? token = storage.read('token');
    int? bloodBankId = storage.read('bloodBankId');
    int? patientId = storage.read('patientId');

    // Step 1: Load cached data (instant UI)
    _loadDataFromStorage();

    // If not logged in -> go to Login
    if (token == null || token.isEmpty) {
      Get.offAll(() => const LoginScreen());
      return;
    }

    //if Logged in: put controllers and navigate immediately (don't wait for network)
    Get.put(DashboardController());
    Get.put(MedicalRecordsController());
    Get.offAllNamed(AppRoutes.dashboard);

    // Step 2: Background tasks (non-blocking)
    //  - Fetch profile (with timeout) and update UI if fresh data available
    //  - Fetch other data in background
    _fetchProfileInBackground(token);
    _fetchBackgroundData(token, bloodBankId, patientId);
  }

  // Load cached data from local storage
  void _loadDataFromStorage() {
    final profileData = storage.read('profileData');
    if (profileData != null) {
      globalProfile.profileData.value = profileData;
    }

    final bankData = storage.read('bloodBankData');
    if (bankData != null) {
      globalProfile.bloodBankData.value = bankData;
    }

    final transfusionData = storage.read('transfusionList');
    if (transfusionData != null) {
      try {
        //parsing with fromJson
        globalProfile.transfusionList.value = TransfusionResponse.fromJson(
          transfusionData,
        );
      } catch (e) {
        debugPrint("Could not parse transfusionList from storage: $e");
      }
    }
  }

  // Fetch profile data in background with timeout
  Future<void> _fetchProfileInBackground(String token) async {
    try {
      final profileData = await ProfileService.fetchProfile(
        token,
      ).timeout(apiTimeout);
      if (profileData != null) {
        globalProfile.profileData.value = profileData;
        storage.write('profileData', profileData);
      }
    } on TimeoutException {
      _showNetworkSnack("Slow internet!");
    } catch (e) {
      (kDebugMode) ? debugPrint("Profile fetch failed: $e") : null;
    }
  }

  // Fetch other data in background with timeout
  Future<void> _fetchBackgroundData(
    String token,
    int? bloodBankId,
    int? patientId,
  ) async {
    // Blood bank
    if (bloodBankId != null) {
      try {
        final bankData = await BloodBankService.fetchBloodBank(
          bloodBankId,
          token,
        ).timeout(apiTimeout);
        if (bankData != null) {
          globalProfile.bloodBankData.value = bankData;
          storage.write('bloodBankData', bankData);
        }
      } on TimeoutException {
        _showNetworkSnack("Slow internet!");
      } catch (e) {
        (kDebugMode) ? debugPrint("Blood bank fetch failed: $e") : null;
      }
    }

    // Transfusion list
    if (patientId != null && bloodBankId != null) {
      try {
        final transfusionData = await TransfusionListService()
            .fetchTransfusions(patientId: patientId, bloodbankId: bloodBankId)
            .timeout(apiTimeout);
        if (transfusionData != null) {
          globalProfile.transfusionList.value = transfusionData;
          storage.write('transfusionList', transfusionData);
        }
      } on TimeoutException {
        // show only once or based on UX; keeping small message
        _showNetworkSnack("Slow internet!");
      } catch (e) {
        (kDebugMode) ? debugPrint("Transfusion list fetch failed: $e") : null;
      }
    }

    // Controller-level fetches (Dashboard, MedicalRecords) - safe calls
    try {
      await Get.find<DashboardController>()
          .fetchRecords()
          .timeout(apiTimeout)
          .catchError((e) {
            (kDebugMode)
                ? debugPrint("DashboardController.fetchRecords error: $e")
                : null;
          });
    } on TimeoutException {
      (kDebugMode)
          ? debugPrint("DashboardController.fetchRecords timed out")
          : null;
    } catch (e) {
      (kDebugMode)
          ? debugPrint("DashboardController.fetchRecords failed: $e")
          : null;
    }

    try {
      await Get.find<MedicalRecordsController>()
          .fetchRecords()
          .timeout(apiTimeout)
          .catchError((e) {
            (kDebugMode)
                ? debugPrint("MedicalRecordsController.fetchRecords error: $e")
                : null;
          });
    } on TimeoutException {
      (kDebugMode)
          ? debugPrint("MedicalRecordsController.fetchRecords timed out")
          : null;
    } catch (e) {
      (kDebugMode)
          ? debugPrint("MedicalRecordsController.fetchRecords failed: $e")
          : null;
    }
  }

  /// Public method to refresh all data (e.g., pull-to-refresh)
  Future<void> refreshAllData() async {
    String? token = storage.read('token');
    int? bloodBankId = storage.read('bloodBankId');
    int? patientId = storage.read('patientId');

    if (token != null && token.isNotEmpty) {
      await _fetchBackgroundData(token, bloodBankId, patientId);
    }
  }

  /// Show network error snack
  void _showNetworkSnack(String message) {
    final context = Get.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
        ),
      );
    }
  }
}
