import 'package:get/get.dart';
import 'package:rudhirakshapp/data/models/doctor_models.dart';
import 'package:rudhirakshapp/routes/app_routes.dart';

class NavigationHelper {
  static void goToLoginScreen() {
    Get.offAllNamed(AppRoutes.login);
  }

  static void goToDashboard() {
    Get.offAllNamed(AppRoutes.dashboard);
  }

  static void goToNotificationScreen() {
    Get.toNamed(AppRoutes.notification);
  }

  static void goToNextTransfusionDetails() {
    Get.toNamed(AppRoutes.nextTransfusionDetails);
  }

  static void goToProfileReview({bool isFromDashboard = false}) {
    Get.toNamed(
      AppRoutes.profileReviewScreen,
      arguments: {'isFromDashboard': isFromDashboard},
    );
  }

  static void goToProfileReviewAfterLogin() {
    Get.offAllNamed(AppRoutes.profileReviewScreen);
  }

  static void goToMedicalRecordsScreen() {
    Get.toNamed(AppRoutes.medicalRecords);
  }

  static void goToTransfusionHistory() {
    Get.toNamed(AppRoutes.medicalRecords);
  }

  static void goToArticles() {
    Get.toNamed(AppRoutes.articles);
  }

  static void goToTerms() {
    Get.toNamed(AppRoutes.terms);
  }

  static void goToBloodBankInfo() {
    Get.toNamed(AppRoutes.bloodBankInfo);
  }

  // Doctor routes
  static void goToDoctorDashboard() {
    Get.offAllNamed(AppRoutes.doctorDashboard);
  }

  static void goToDoctorPatientDetail(int patientId, AssignedPatient patient) {
    Get.toNamed(
      AppRoutes.doctorPatientDetail,
      arguments: {'patientId': patientId, 'patient': patient},
    );
  }
}
