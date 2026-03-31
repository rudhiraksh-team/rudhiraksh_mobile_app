import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:rudhirakshapp/controllers/global_profile_controller.dart';
import 'package:rudhirakshapp/data/models/transfusion_list_model.dart';
import 'package:rudhirakshapp/data/services/transfusion_list_service.dart';

class MedicalRecordsController extends GetxController {
  final globalProfile = Get.find<GlobalProfileController>();

  // Observables
  var records = <Transfusion>[].obs;
  var isLoading = false.obs;
  var isDataLoaded = false.obs;

  // init
  @override
  void onInit() {
    super.onInit();
    fetchRecords();
  }

  //Fetch Records
  Future<void> fetchRecords() async {
    isLoading.value = true;

    //
    try {
      final profile = globalProfile.profileData;
      final bloodBank = globalProfile.bloodBankData;

      if (profile.isEmpty || bloodBank.isEmpty) {
        isLoading.value = false;
        return;
      }

      final patientId = profile['data']['patient']['id'];
      final bloodBankId = bloodBank['data']['id'];

      final transfusionsResponse = await TransfusionListService()
          .fetchTransfusions(patientId: patientId, bloodbankId: bloodBankId);

      if (transfusionsResponse != null) {
        List<Transfusion> tempList = [];

        // Add DONE transfusions
        if (transfusionsResponse.data?.transfusions.isNotEmpty == true) {
          tempList.addAll(transfusionsResponse.data!.transfusions);
        }

        // Add all MISSED transfusions (without date check)
        final missedList = transfusionsResponse.data?.missedTransfusions ?? [];
        for (var missed in missedList) {
          if (missed.expectedDate != null) {
            tempList.add(
              Transfusion(
                id: null,
                patientId: patientId,
                visitDate: missed.expectedDate,
                unitBloodGroup:
                    tempList.isNotEmpty ? tempList.first.unitBloodGroup : "",
                attendingStaff:
                    tempList.isNotEmpty ? tempList.first.attendingStaff : null,
                notes: null,
                bloodbankId:
                    tempList.isNotEmpty ? tempList.first.bloodbankId : 0,
                medications: null,
              ),
            );
          }
        }

        // Add UPCOMING transfusion
        final nextDate = transfusionsResponse.data?.nextTransfusion;
        if (nextDate != null) {
          bool alreadyExists = tempList.any(
            (r) =>
                r.visitDate != null &&
                r.visitDate!.year == nextDate.year &&
                r.visitDate!.month == nextDate.month &&
                r.visitDate!.day == nextDate.day,
          );

          if (!alreadyExists) {
            tempList.add(
              Transfusion(
                id: null,
                patientId: patientId,
                visitDate: nextDate,
                unitBloodGroup:
                    tempList.isNotEmpty ? tempList.first.unitBloodGroup : "",
                attendingStaff:
                    tempList.isNotEmpty ? tempList.first.attendingStaff : null,
                notes: null,
                bloodbankId:
                    tempList.isNotEmpty ? tempList.first.bloodbankId : 0,
                medications: null,
              ),
            );
          }
        }

        // Sort by date desc
        tempList.sort((a, b) => b.visitDate!.compareTo(a.visitDate!));
        records.value = tempList;
        globalProfile.setTransfusionList(transfusionsResponse);
      } else {
        records.clear();
      }

      isDataLoaded.value = true;
    } catch (e) {
      if (kDebugMode) print('Error fetching records: $e');
    } finally {
      isLoading.value = false;
    }
    update(); //Force UI refresh after data load
  }

  Future<void> refreshRecords() async {
    await fetchRecords();
  }

  String getRecordStatus(Transfusion record) {
    // 1. If record has ID -> it's DONE
    if (record.id != null) return "Done";

    // 2. Check if it's UPCOMING
    final nextDate = globalProfile.transfusionList.value?.data?.nextTransfusion;
    if (nextDate != null &&
        record.visitDate != null &&
        record.visitDate!.year == nextDate.year &&
        record.visitDate!.month == nextDate.month &&
        record.visitDate!.day == nextDate.day) {
      return "Upcoming";
    }

    // 3. Otherwise it's MISSED
    return "Missed";
  }
}
