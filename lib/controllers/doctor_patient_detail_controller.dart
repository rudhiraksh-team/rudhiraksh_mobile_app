import 'dart:io';
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
  var ferritinEntries = <FerritinEntry>[].obs;
  var chelationEntries = <ChelationEntry>[].obs;
  var images = <PatientImage>[].obs;
  var isLoading = false.obs;
  var isMutating = false.obs;
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
      _fetchFerritin(),
      _fetchChelation(),
      _fetchImages(),
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

  Future<void> _fetchFerritin() async {
    try {
      final response = await DoctorService.fetchPatientFerritinHistory(patientId);
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        ferritinEntries.value = data
            .map((e) => FerritinEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('fetchFerritin error: $e');
    }
  }

  Future<void> _fetchChelation() async {
    try {
      final response = await DoctorService.fetchPatientChelationHistory(patientId);
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        chelationEntries.value = data
            .map((e) => ChelationEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('fetchChelation error: $e');
    }
  }

  Future<void> _fetchImages() async {
    try {
      final response = await DoctorService.fetchPatientImages(patientId);
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        images.value = data
            .map((e) => PatientImage.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('fetchImages error: $e');
    }
  }

  Future<bool> createTransfusion(Map<String, dynamic> body) async {
    isMutating.value = true;
    final result = await DoctorService.createTransfusion(patientId, body);
    isMutating.value = false;
    if (result['success'] == true) {
      await _fetchTransfusions();
      return true;
    }
    Get.snackbar('Error', result['message'] ?? 'Failed to create transfusion',
        snackPosition: SnackPosition.BOTTOM);
    return false;
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

  Future<bool> reviewLabRequest(int id) async {
    isMutating.value = true;
    final result = await DoctorService.reviewLabRequest(id);
    isMutating.value = false;
    if (result['success'] == true) {
      await _fetchLabRequests();
      return true;
    }
    Get.snackbar('Error', result['message'] ?? 'Failed to mark reviewed',
        snackPosition: SnackPosition.BOTTOM);
    return false;
  }

  Future<bool> updateLabRequest(int id, Map<String, dynamic> body) async {
    isMutating.value = true;
    final result = await DoctorService.updateLabRequest(id, body);
    isMutating.value = false;
    if (result['success'] == true) {
      await _fetchLabRequests();
      return true;
    }
    Get.snackbar('Error', result['message'] ?? 'Failed to update',
        snackPosition: SnackPosition.BOTTOM);
    return false;
  }

  Future<bool> deleteLabRequest(int id) async {
    isMutating.value = true;
    final result = await DoctorService.deleteLabRequest(id);
    isMutating.value = false;
    if (result['success'] == true) {
      await _fetchLabRequests();
      return true;
    }
    Get.snackbar('Error', result['message'] ?? 'Failed to delete',
        snackPosition: SnackPosition.BOTTOM);
    return false;
  }

  /// Upload a file then create a document row linked to this patient.
  Future<bool> uploadDocument({
    required File file,
    String? documentType,
    String? notes,
  }) async {
    isMutating.value = true;
    try {
      final uploaded = await DoctorService.uploadFile(file);
      if (uploaded == null) {
        Get.snackbar('Upload failed', 'Could not upload file',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
      final result = await DoctorService.createDocument(
        patientId,
        fileUrl: uploaded['fileUrl'],
        fileName: uploaded['fileName'],
        documentType: documentType,
        notes: notes,
      );
      if (result['success'] == true) {
        await _fetchDocuments();
        return true;
      }
      Get.snackbar('Error', result['message'] ?? 'Failed to save document',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  Future<bool> updateDocument(int id, Map<String, dynamic> body) async {
    isMutating.value = true;
    final result = await DoctorService.updateDocument(id, body);
    isMutating.value = false;
    if (result['success'] == true) {
      await _fetchDocuments();
      return true;
    }
    Get.snackbar('Error', result['message'] ?? 'Failed to update',
        snackPosition: SnackPosition.BOTTOM);
    return false;
  }

  Future<bool> deleteDocument(int id) async {
    isMutating.value = true;
    final result = await DoctorService.deleteDocument(id);
    isMutating.value = false;
    if (result['success'] == true) {
      await _fetchDocuments();
      return true;
    }
    Get.snackbar('Error', result['message'] ?? 'Failed to delete',
        snackPosition: SnackPosition.BOTTOM);
    return false;
  }
}
