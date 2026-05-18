import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rudhirakshapp/data/models/doctor_models.dart';
import 'package:rudhirakshapp/data/services/patient_lab_request_service.dart';

class PatientLabRequestsController extends GetxController {
  var labRequests = <LabRequest>[].obs;
  var isLoading = false.obs;
  var isUploading = false.obs;

  int get pendingCount =>
      labRequests.where((r) => r.status == 'requested').length;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    try {
      final data = await PatientLabRequestService.fetchLabRequests();
      labRequests.value = data
          .map((e) => LabRequest.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint('fetch lab requests error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> uploadReport({
    required int labRequestId,
    required File file,
    String? notes,
  }) async {
    isUploading.value = true;
    try {
      final result = await PatientLabRequestService.uploadLabReport(
        labRequestId: labRequestId,
        file: file,
        notes: notes,
      );
      if (result['success'] == true) {
        await fetch();
        return true;
      }
      Get.snackbar(
        'Upload failed',
        result['message'] ?? 'Could not attach report',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isUploading.value = false;
    }
  }
}
