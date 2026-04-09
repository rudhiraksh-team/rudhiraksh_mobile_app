import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rudhirakshapp/data/models/doctor_models.dart';
import 'package:rudhirakshapp/data/models/transfusion_list_model.dart';
import 'package:rudhirakshapp/data/services/doctor_service.dart';

class DoctorPatientDetailController extends GetxController {
  final int patientId;
  DoctorPatientDetailController({required this.patientId});

  var transfusions = <Transfusion>[].obs;
  var growthEntries = <GrowthEntry>[].obs;
  var documents = <PatientDocument>[].obs;
  var labRequests = <LabRequest>[].obs;
  var isLoading = false.obs;
  var selectedTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    await Future.wait([
      _fetchTransfusions(),
      _fetchGrowthEntries(),
      _fetchDocuments(),
      _fetchLabRequests(),
    ]);
    isLoading.value = false;
  }

  Future<void> _fetchTransfusions() async {
    try {
      final response = await DoctorService.fetchPatientTransfusions(patientId);
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        transfusions.value = data
            .map((e) => Transfusion.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('fetchTransfusions error: $e');
    }
  }

  Future<void> _fetchGrowthEntries() async {
    try {
      final response = await DoctorService.fetchPatientGrowthEntries(patientId);
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        growthEntries.value = data
            .map((e) => GrowthEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('fetchGrowthEntries error: $e');
    }
  }

  Future<void> _fetchDocuments() async {
    try {
      final response = await DoctorService.fetchPatientDocuments(patientId);
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        documents.value = data
            .map((e) => PatientDocument.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('fetchDocuments error: $e');
    }
  }

  Future<void> _fetchLabRequests() async {
    try {
      final response = await DoctorService.fetchPatientLabRequests(patientId);
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        labRequests.value = data
            .map((e) => LabRequest.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('fetchLabRequests error: $e');
    }
  }

  Future<bool> createLabRequest(String testName, {String? labName, String? notes}) async {
    final result = await DoctorService.createLabRequest(
      patientId,
      testName: testName,
      labName: labName,
      notes: notes,
    );
    if (result['success'] == true) {
      await _fetchLabRequests();
      return true;
    }
    Get.snackbar('Error', result['message'] ?? 'Failed to create request',
        snackPosition: SnackPosition.BOTTOM);
    return false;
  }
}
