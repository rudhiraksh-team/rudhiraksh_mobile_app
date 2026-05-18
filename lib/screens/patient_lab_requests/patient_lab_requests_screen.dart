import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/controllers/patient_lab_requests_controller.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/data/models/doctor_models.dart';
import 'package:rudhirakshapp/screens/patient_lab_requests/upload_lab_report_sheet.dart';

class PatientLabRequestsScreen extends StatelessWidget {
  const PatientLabRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final controller = Get.put(PatientLabRequestsController());

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: colors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(SolarLinearIcons.arrowLeft, color: colors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Lab Requests',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.labRequests.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: colors.primaryColor),
          );
        }

        if (controller.labRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(SolarLinearIcons.testTube, size: 56, color: colors.textSecondary),
                const SizedBox(height: 12),
                Text(
                  'No lab requests yet',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "When your doctor requests a test, it'll appear here.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: colors.primaryColor,
          onRefresh: controller.fetch,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: controller.labRequests.length,
            itemBuilder: (context, index) {
              final req = controller.labRequests[index];
              return _LabRequestCard(
                req: req,
                onUpload: () => _openUploadSheet(context, controller, req),
              );
            },
          ),
        );
      }),
    );
  }

  void _openUploadSheet(
    BuildContext context,
    PatientLabRequestsController controller,
    LabRequest req,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => UploadLabReportSheet(
        labRequest: req,
        onSubmit: (file, notes) =>
            controller.uploadReport(labRequestId: req.id, file: file, notes: notes),
      ),
    );
  }
}

class _LabRequestCard extends StatelessWidget {
  final LabRequest req;
  final VoidCallback onUpload;

  const _LabRequestCard({required this.req, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    Color statusColor;
    switch (req.status) {
      case 'uploaded':
        statusColor = AppColors.info;
        break;
      case 'reviewed':
        statusColor = AppColors.success;
        break;
      default:
        statusColor = AppColors.warning;
    }

    final isPending = req.status == 'requested';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  SolarLinearIcons.testTube,
                  size: 20,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.testName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (req.requestedByName != null && req.requestedByName!.isNotEmpty)
                          'Requested by Dr. ${req.requestedByName}',
                        req.formattedDate,
                      ].where((s) => s.isNotEmpty).join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  req.statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (req.labName != null && req.labName!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Lab: ${req.labName}',
                style: TextStyle(color: colors.textSecondary, fontSize: 12)),
          ],
          if (req.formattedDueDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  SolarLinearIcons.calendar,
                  size: 14,
                  color: req.isOverdue ? AppColors.error : colors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  req.isOverdue
                      ? 'Overdue: ${req.formattedDueDate}'
                      : 'Due by ${req.formattedDueDate}',
                  style: TextStyle(
                    color: req.isOverdue ? AppColors.error : colors.textSecondary,
                    fontSize: 12,
                    fontWeight: req.isOverdue ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          if (req.notes != null && req.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(req.notes!,
                style: TextStyle(color: colors.textSecondary, fontSize: 12)),
          ],
          if (isPending) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: onUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upload_file, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Upload Report',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
