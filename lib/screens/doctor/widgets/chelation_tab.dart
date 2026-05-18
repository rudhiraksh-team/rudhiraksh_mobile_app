import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/controllers/doctor_patient_detail_controller.dart';

class ChelationTab extends StatelessWidget {
  final DoctorPatientDetailController controller;

  const ChelationTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return Obx(() {
      if (controller.chelationEntries.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(SolarLinearIcons.pill, size: 48, color: colors.textSecondary),
              const SizedBox(height: 12),
              Text(
                'No chelation records yet',
                style: TextStyle(color: colors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchAll(),
        color: colors.primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.chelationEntries.length,
          itemBuilder: (context, index) {
            final e = controller.chelationEntries[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceColor,
                borderRadius: BorderRadius.circular(12),
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
                          color: AppColors.indigo.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          SolarLinearIcons.pill,
                          size: 20,
                          color: AppColors.indigo,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.medication ?? 'Medication',
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (e.dosage != null && e.dosage!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                e.dosage!,
                                style: TextStyle(color: colors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _kv(colors, 'Start', e.startFormatted),
                      ),
                      Expanded(
                        child: _kv(colors, 'End', e.endFormatted),
                      ),
                    ],
                  ),
                  if (e.notes != null && e.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      e.notes!,
                      style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _kv(AppThemeColors colors, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: colors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
