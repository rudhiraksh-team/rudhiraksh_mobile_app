import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudhirakshapp/controllers/medical_records_controller.dart';
import 'package:rudhirakshapp/core/constants/app_strings.dart';
import 'record_item.dart';
import 'transfusion_charts.dart';

class RecordsList extends StatelessWidget {
  final controller = Get.put(MedicalRecordsController());

  RecordsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.records.isEmpty) {
        return Center(child: Text(AppStrings.noRecordsFound));
      }

      // Separate lists based on status
      final upcoming =
          controller.records
              .where((r) => controller.getRecordStatus(r) == "Upcoming")
              .toList();
      final missed =
          controller.records
              .where((r) => controller.getRecordStatus(r) == "Missed")
              .toList();
      final done =
          controller.records
              .where((r) => controller.getRecordStatus(r) == "Done")
              .toList();

      // Sort
      upcoming.sort((a, b) => a.visitDate!.compareTo(b.visitDate!));
      missed.sort((a, b) => a.visitDate!.compareTo(b.visitDate!));
      done.sort((a, b) => b.visitDate!.compareTo(a.visitDate!));

      // Final merged list
      final sortedList = [...upcoming, ...missed, ...done];

      return RefreshIndicator(
        onRefresh: controller.refreshRecords,
        child: CustomScrollView(
          slivers: [
            // Charts at top
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: TransfusionCharts(records: controller.records),
              ),
            ),
            // Record list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final record = sortedList[index];
                  final status = controller.getRecordStatus(record);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: RecordItem(record: record, status: status),
                  );
                },
                childCount: sortedList.length,
              ),
            ),
          ],
        ),
      );
    });
  }
}
