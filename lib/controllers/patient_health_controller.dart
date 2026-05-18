import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rudhirakshapp/data/services/patient_portal_service.dart';

class PatientHealthController extends GetxController {
  var isLoading = false.obs;
  var growthEntries = <Map<String, dynamic>>[].obs;
  var ferritinEntries = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        PatientPortalService.fetchGrowthEntries(),
        PatientPortalService.fetchFerritinHistory(),
      ]);
      growthEntries.value = results[0].cast<Map<String, dynamic>>();
      ferritinEntries.value = results[1].cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('PatientHealthController fetchAll error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() async => fetchAll();
}
