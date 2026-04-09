import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:rudhirakshapp/data/helper%20function/navigation_helper.dart';
import 'package:rudhirakshapp/data/models/transfusion_list_model.dart'
    as tmodel;
import '../core/utils/common_utils.dart';

class DashboardController extends GetxController {
  //local storage instance
  final GetStorage storage = GetStorage();

  var userName = ''.obs; // User's full name
  var bloodBankName = ''.obs; // Blood bank name
  var bloodBankPhoto = ''.obs; // Blood bank logo URL

  // Separate lists for different record types
  RxList<tmodel.Transfusion> doneTransfusions = <tmodel.Transfusion>[].obs;
  RxList<tmodel.MissedTransfusion> missedTransfusions =
      <tmodel.MissedTransfusion>[].obs;
  var upcomingTransfusion = Rxn<tmodel.Transfusion>();
  var selectedDate = Rxn<DateTime>();
  var bottomNavIndex = 0.obs;
  var selectedTransfusionRx = Rxn<tmodel.Transfusion>();

  @override
  void onInit() {
    super.onInit();
    // Initial load from storage
    loadTransfusionsFromStorage();
  }

  //Public method to refresh data
  Future<void> fetchRecords() async {
    await loadTransfusionsFromStorage();
    update(); // Force UI refresh
  }

  Future<void> loadTransfusionsFromStorage() async {
    try {
      final cached = storage.read<String>('transfusions_json');
      if (cached == null) {
        // No cached data: leave selectedDate null (so nothing selected)
        doneTransfusions.clear();
        missedTransfusions.clear();
        upcomingTransfusion.value = null;
        updateSelectedTransfusion();
        return;
      }

      final Map<String, dynamic> decoded = json.decode(cached);
      final rawData = decoded['data'];

      // Handle both formats: structured { transfusions, next_transfusion, ... } and flat array
      late final List doneList;
      late final dynamic nextTransRaw;
      late final List missedRaw;

      if (rawData is Map) {
        final data = Map<String, dynamic>.from(rawData);
        doneList = data['transfusions'] ?? [];
        nextTransRaw = data['next_transfusion'];
        missedRaw = List.from(data['missed_transfusions'] ?? []);
      } else if (rawData is List) {
        // Flat array from older API format
        doneList = rawData;
        nextTransRaw = null;
        missedRaw = [];
      } else {
        doneList = [];
        nextTransRaw = null;
        missedRaw = [];
      }

      // Clear existing data
      doneTransfusions.clear();
      missedTransfusions.clear();
      upcomingTransfusion.value = null;

      // Parse DONE transfusions
      for (final item in doneList) {
        try {
          final t = tmodel.Transfusion.fromJson(
            Map<String, dynamic>.from(item),
          );
          doneTransfusions.add(t);
        } catch (e) {
          debugPrint('Failed to parse transfusion item: $e');
        }
      }

      // Parse MISSED transfusions
      for (final m in missedRaw) {
        try {
          final mt = tmodel.MissedTransfusion.fromJson(
            Map<String, dynamic>.from(m),
          );
          missedTransfusions.add(mt);
        } catch (e) {
          debugPrint('Failed to parse missed transfusion: $e');
        }
      }

      // Parse UPCOMING transfusion
      if (nextTransRaw != null) {
        DateTime? nextDt;
        if (nextTransRaw is String) {
          nextDt = DateTime.tryParse(nextTransRaw)?.toLocal();
        } else if (nextTransRaw is Map && (nextTransRaw['date'] != null)) {
          nextDt =
              DateTime.tryParse(
                nextTransRaw['date']?.toString() ?? '',
              )?.toLocal();
        }

        if (nextDt != null) {
          // Create upcoming transfusion and ALSO set nextTransfusionDate
          upcomingTransfusion.value = tmodel.Transfusion(
            id: null,
            patientId: 0,
            visitDate: nextDt,
            startTime: nextDt,
            endTime: null,
            medications: null,
            // ensure model's nextTransfusionDate property is set
            nextTransfusionDate: nextDt,
          );

          // Set selectedDate to upcoming date (so it's selected by default)
          selectedDate.value = DateTime(nextDt.year, nextDt.month, nextDt.day);
        }
      } else {
        // No upcoming: leave selectedDate null (so today is NOT selected)
        selectedDate.value = null;
      }

      // Update selected transfusion after load (selectedDate is already set above)
      updateSelectedTransfusion();
    } catch (e) {
      debugPrint("Error parsing transfusions_json: $e");
    }
  }

  // Update selected transfusion
  void updateSelectedTransfusion() {
    if (selectedDate.value == null) {
      selectedTransfusionRx.value = null;
      return;
    }

    final date = selectedDate.value!;

    // Check done transfusions
    for (var t in doneTransfusions) {
      final dt = _modelDateTime(t);
      if (dt != null &&
          dt.year == date.year &&
          dt.month == date.month &&
          dt.day == date.day) {
        selectedTransfusionRx.value = t;
        return;
      }
    }

    // Check upcoming transfusion
    if (upcomingTransfusion.value != null) {
      final dt = _modelDateTime(upcomingTransfusion.value!);
      if (dt != null &&
          dt.year == date.year &&
          dt.month == date.month &&
          dt.day == date.day) {
        selectedTransfusionRx.value = upcomingTransfusion.value;
        return;
      }
    }

    // Check missed transfusions
    for (var m in missedTransfusions) {
      if (m.expectedDate != null &&
          m.expectedDate!.year == date.year &&
          m.expectedDate!.month == date.month &&
          m.expectedDate!.day == date.day) {
        // Create a synthetic transfusion for UI purposes
        selectedTransfusionRx.value = tmodel.Transfusion(
          id: null,
          patientId: 0,
          visitDate: m.expectedDate,
          startTime: m.expectedDate,
          endTime: null,
          medications: null,
          nextTransfusionDate: m.expectedDate,
        );
        return;
      }
    }

    selectedTransfusionRx.value = null;
  }

  // Update the date extraction logic
  DateTime? _modelDateTime(tmodel.Transfusion t) {
    // For done transfusions, use visit_date as primary
    if (t.id != null) return t.visitDate;
    // For upcoming, use nextTransfusionDate
    return t.nextTransfusionDate;
  }

  // Date formatting
  String _displayDateFor(tmodel.Transfusion t) {
    final dt = _modelDateTime(t);
    if (dt == null) return '-';
    try {
      return dateFmt.format(dt);
    } catch (_) {
      return DateFormat('dd MMM yyyy').format(dt);
    }
  }

  // Time formatting
  String _timeFor(tmodel.Transfusion t) {
    // Prefer visitDate, else nextTransfusionDate
    final dt = t.visitDate ?? t.nextTransfusionDate;
    if (dt == null) return "";
    return DateFormat("HH:mm").format(dt);
  }

  // Handle date selection from UI
  void onDateSelected(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
    updateSelectedTransfusion();
  }

  // Handle bottom nav tap
  void onBottomNavTap(int index) {
    bottomNavIndex.value = index;
    if (index == 1) {
      NavigationHelper.goToNextTransfusionDetails();
    } else if (index == 2) {
      NavigationHelper.goToProfileReview();
    }
  }

  // Set profile and blood bank data
  void setProfileAndBloodBankData(
    Map<String, dynamic> profileData,
    Map<String, dynamic> bloodBankData,
  ) {
    final patient = profileData['data']?['patient'] ?? profileData['data'];
    userName.value = patient?['full_name'] ?? patient?['name'] ?? '';
    bloodBankName.value = bloodBankData['data']?['name'] ?? '';
    bloodBankPhoto.value = bloodBankData['data']?['logo_url'] ?? bloodBankData['data']?['logoUrl'] ?? '';
  }

  // UI helpers
  String displayDateForSelected() {
    final s = selectedTransfusionRx.value;
    if (s == null) return '-';
    return _displayDateFor(s);
  }

  // Time formatting for selected transfusion
  String timeForSelected() {
    final s = selectedTransfusionRx.value;
    if (s == null) return '';
    return _timeFor(s);
  }
}
