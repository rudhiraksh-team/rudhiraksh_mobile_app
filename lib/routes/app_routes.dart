import 'package:get/get.dart';
import 'package:rudhirakshapp/screens/Login/login_screen.dart';
import 'package:rudhirakshapp/screens/user%20profile/profile_review_screen.dart';
import 'package:rudhirakshapp/screens/dashboard/dashboard_screen.dart';
import 'package:rudhirakshapp/screens/transfusion%20details/next_transfusion_details_screen.dart';
import 'package:rudhirakshapp/screens/medical%20history/medical_records_screen.dart';
import 'package:rudhirakshapp/screens/medical%20history/transfusion_record_detail_screen.dart';
import 'package:rudhirakshapp/screens/notification/notification%20screen/notification_screen.dart';
import 'package:rudhirakshapp/screens/splash/splash_screen.dart';
import 'package:rudhirakshapp/screens/articles/articles_screen.dart';
import 'package:rudhirakshapp/screens/terms/terms_screen.dart';
import 'package:rudhirakshapp/screens/bloodbank_info/bloodbank_info_screen.dart';
import 'package:rudhirakshapp/screens/doctor/doctor_dashboard_screen.dart';
import 'package:rudhirakshapp/screens/doctor/doctor_patient_detail_screen.dart';

class AppRoutes {
  // Route Names
  static const String splash = '/';

  // Login Flow
  static const String login = '/login';
  static const String profileReviewScreen = '/login/profile-review-screen';

  // Dashboard (Patient)
  static const String dashboard = '/dashboard';
  static const String nextTransfusionDetails = '/dashboard/next-transfusion-details';

  // Doctor Dashboard
  static const String doctorDashboard = '/doctor-dashboard';
  static const String doctorPatientDetail = '/doctor-dashboard/patient-detail';

  // Notification
  static const String notification = '/dashboard/notification';

  // Medical Records
  static const String medicalRecords = '/dashboard/medical-records';
  static const String transfusionRecordDetail = '/dashboard/transfusion-record-detail';

  // Articles / Feed
  static const String articles = '/articles';

  // Terms & Conditions / Privacy Policy
  static const String terms = '/terms';

  // Blood Bank Info
  static const String bloodBankInfo = '/blood-bank-info';

  // GetX Page Routes
  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: profileReviewScreen, page: () => const ProfileReviewScreen()),
    GetPage(name: dashboard, page: () => const DashboardScreen()),
    GetPage(name: nextTransfusionDetails, page: () => const NextTransfusionDetailsScreen()),
    GetPage(name: notification, page: () => const NotificationScreen()),
    GetPage(name: medicalRecords, page: () => const MedicalRecordsScreen()),
    GetPage(name: transfusionRecordDetail, page: () => const TransfusionRecordDetailScreen()),
    GetPage(name: articles, page: () => const ArticlesScreen()),
    GetPage(name: terms, page: () => const TermsScreen()),
    GetPage(name: bloodBankInfo, page: () => const BloodBankInfoScreen()),
    GetPage(name: doctorDashboard, page: () => const DoctorDashboardScreen()),
    GetPage(name: doctorPatientDetail, page: () => const DoctorPatientDetailScreen()),
  ];
}
