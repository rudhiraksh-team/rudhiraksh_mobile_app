import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/controllers/doctor_patient_detail_controller.dart';

class TransfusionListTab extends StatelessWidget {
  final DoctorPatientDetailController controller;

  const TransfusionListTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return Obx(() {
      if (controller.transfusions.isEmpty) {
        return _EmptyState(
          icon: SolarLinearIcons.waterdrop,
          message: 'No transfusion records found',
          colors: colors,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.transfusions.length,
        itemBuilder: (context, index) {
          final t = controller.transfusions[index];
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.brandCrimson.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            SolarLinearIcons.waterdrop,
                            size: 18,
                            color: AppColors.brandCrimson,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          t.formatDate(t.visitDate),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (t.transfusionType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t.transfusionType!,
                          style: const TextStyle(
                            color: AppColors.info,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatItem(
                      label: 'Pre HB',
                      value: t.preHb != null ? '${t.preHb!.toStringAsFixed(1)} g/dL' : 'N/A',
                      color: AppColors.brandRed,
                      colors: colors,
                    ),
                    const SizedBox(width: 20),
                    _StatItem(
                      label: 'Volume',
                      value: t.volumeMl != null ? '${t.volumeMl} mL' : 'N/A',
                      color: AppColors.indigo,
                      colors: colors,
                    ),
                    const SizedBox(width: 20),
                    _StatItem(
                      label: 'Blood Group',
                      value: t.unitBloodGroup ?? 'N/A',
                      color: AppColors.teal,
                      colors: colors,
                    ),
                  ],
                ),
                if (t.reactionSeverity != null && t.reactionSeverity!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Reaction: ${t.reactionSeverity}',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );
    });
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final AppThemeColors colors;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final AppThemeColors colors;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: colors.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
