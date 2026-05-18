import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/controllers/doctor_patient_detail_controller.dart';
import 'package:rudhirakshapp/data/models/doctor_models.dart';
import 'package:rudhirakshapp/data/helper%20function/file_viewer_helper.dart';
import 'package:rudhirakshapp/screens/doctor/widgets/create_lab_request_sheet.dart';

class LabRequestsTab extends StatelessWidget {
  final DoctorPatientDetailController controller;

  const LabRequestsTab({super.key, required this.controller});

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CreateLabRequestSheet(
        onSubmit: (testName, {labName, notes}) =>
            controller.createLabRequest(testName, labName: labName, notes: notes),
      ),
    );
  }

  Future<void> _confirmReview(BuildContext context, LabRequest req) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mark as reviewed?'),
        content: Text('Confirm you have reviewed the report for "${req.testName}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark reviewed'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.reviewLabRequest(req.id);
    }
  }

  Future<void> _confirmDelete(BuildContext context, LabRequest req) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete lab request?'),
        content: Text('Remove the request for "${req.testName}" permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteLabRequest(req.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return Stack(
      children: [
        Obx(() {
          if (controller.labRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(SolarLinearIcons.testTube, size: 48, color: colors.textSecondary),
                  const SizedBox(height: 12),
                  Text('No report requests yet',
                      style: TextStyle(color: colors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('Tap + to request a report',
                      style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchAll(),
            color: colors.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: controller.labRequests.length,
              itemBuilder: (context, index) {
                final req = controller.labRequests[index];
                return _LabRequestCard(
                  req: req,
                  onViewReport: () => FileViewerHelper.showViewerSheet(
                    context,
                    url: req.documentFileUrl,
                    fileName: req.documentFileName,
                  ),
                  onReview: () => _confirmReview(context, req),
                  onDelete: () => _confirmDelete(context, req),
                );
              },
            ),
          );
        }),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'doctor-lab-create',
            onPressed: () => _showCreateSheet(context),
            backgroundColor: AppColors.doctorGreen,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Request'),
          ),
        ),
      ],
    );
  }
}

class _LabRequestCard extends StatelessWidget {
  final LabRequest req;
  final VoidCallback onViewReport;
  final VoidCallback onReview;
  final VoidCallback onDelete;

  const _LabRequestCard({
    required this.req,
    required this.onViewReport,
    required this.onReview,
    required this.onDelete,
  });

  Color _statusColor() {
    switch (req.status) {
      case 'uploaded':
        return AppColors.info;
      case 'reviewed':
        return AppColors.success;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final statusColor = _statusColor();
    final hasReport = req.documentFileUrl != null && req.documentFileUrl!.isNotEmpty;
    final isUploaded = req.status == 'uploaded';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
                child: Icon(SolarLinearIcons.testTube, size: 20, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.testName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        req.formattedDate,
                        if (req.labName != null && req.labName!.isNotEmpty) req.labName!,
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
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: colors.textSecondary, size: 20),
                onSelected: (v) {
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
          if (req.notes != null && req.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              req.notes!,
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (hasReport) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: onViewReport,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.borderColor),
                ),
                child: Row(
                  children: [
                    Icon(SolarLinearIcons.eye, size: 16, color: colors.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        req.documentFileName ?? 'View report',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.open_in_new, size: 14, color: colors.textSecondary),
                  ],
                ),
              ),
            ),
          ],
          if (isUploaded) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onReview,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Mark as reviewed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
