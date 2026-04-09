import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rudhirakshapp/data/models/doctor_models.dart';
import 'package:rudhirakshapp/data/services/doctor_service.dart';

class DoctorDashboardController extends GetxController {
  final storage = GetStorage();

  var bottomNavIndex = 0.obs;
  var assignedPatients = <AssignedPatient>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  List<AssignedPatient> get filteredPatients {
    if (searchQuery.value.isEmpty) return assignedPatients;
    final query = searchQuery.value.toLowerCase();
    return assignedPatients.where((p) {
      return p.name.toLowerCase().contains(query) ||
          (p.bloodGroup?.toLowerCase().contains(query) ?? false) ||
          (p.phone?.contains(query) ?? false);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchAssignedPatients();
  }

  Future<void> fetchAssignedPatients() async {
    try {
      isLoading.value = true;
      final response = await DoctorService.fetchAssignedPatients();
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        assignedPatients.value =
            data.map((e) => AssignedPatient.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      debugPrint('fetchAssignedPatients error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchAssignedPatients();
  }
}
