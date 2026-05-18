import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rudhirakshapp/data/helper%20function/navigation_helper.dart';
import 'global_profile_controller.dart';

// Controller to handle user logout functionality
class LogoutController extends GetxController {
  final box = GetStorage(); // Local storage instance
  final isLoggingOut = false.obs; // Tracks logout state

  Future<void> logoutImmediate() async {
    try {
      isLoggingOut.value = true; // Mark logout in progress

      // 1) Delete FCM token from Firebase and local storage
      try {
        await FirebaseMessaging.instance
            .deleteToken(); // Remove FCM token from Firebase
        await box.remove('fcmToken'); // Remove FCM token from local storage
      } catch (e) {
        if (kDebugMode) print('Error deleting FCM token: $e');  
      }

      // 2) Clear all saved data from local storage
      await box.erase();

      // 3) Reset global profile controller state if it exists
      if (Get.isRegistered<GlobalProfileController>()) {
        final gp = Get.find<GlobalProfileController>();
        gp.profileData.clear();
        gp.profileData.refresh();
        gp.bloodBankData.clear();
        gp.bloodBankData.refresh();
        gp.transfusionList.value = null;
        gp.transfusionList.refresh();
      }

      // 4) Navigate back to login screen and clear navigation stack
      NavigationHelper.goToLoginScreen();
    } catch (e) {
      Get.snackbar('Error', 'Unable to logout. Try again.');
    } finally {
      isLoggingOut.value = false; // Reset logout state
    }
  }
}
