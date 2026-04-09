import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/controllers/doctor_patient_detail_controller.dart';
import 'package:rudhirakshapp/screens/doctor/widgets/create_lab_request_sheet.dart';

class LabRequestsTab extends StatelessWidget {
  final DoctorPatientDetailController controller;

  const LabRequestsTab({super.key, required this.controller});

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
                  Text(
                    'No report requests yet',
                    style: TextStyle(color: colors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to request a report from the Blood Bank',
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: controller.labRequests.length,
            itemBuilder: (context, index) {
              final req = controller.labRequests[index];

              Color statusColor;
              switch (req.status) {
                case 'uploaded':
                  statusColor = AppColors.success;
                  break;
                case 'reviewed':
                  statusColor = AppColors.info;
                  break;
                default:
                  statusColor = AppColors.warning;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.borderColor),
                ),
                child: Row(
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
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                req.formattedDate,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              if (req.labName != null) ...[
                                Text(
                                  ' \u2022 ',
                                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                                ),
                                Text(
                                  req.labName!,
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (req.notes != null && req.notes!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              req.notes!,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 11,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
        // FAB
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () => _showCreateSheet(context),
            backgroundColor: AppColors.brandCrimson,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

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
}
