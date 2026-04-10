import 'package:flutter/material.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/data/models/doctor_models.dart';

class PatientCard extends StatelessWidget {
  final AssignedPatient patient;
  final VoidCallback onTap;

  const PatientCard({super.key, required this.patient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final daysLeft = patient.daysUntilNextTransfusion;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row: Avatar + Name + HB ──
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      AppColors.doctorGreen.withValues(alpha: 0.1),
                  child: Text(
                    patient.initials,
                    style: const TextStyle(
                      color: AppColors.doctorGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (patient.age.isNotEmpty)
                            _InfoChip(
                              icon: SolarLinearIcons.userRounded,
                              label: patient.age,
                              colors: colors,
                            ),
                          if (patient.bloodGroup != null &&
                              patient.bloodGroup!.isNotEmpty)
                            _InfoChip(
                              icon: SolarLinearIcons.waterdrop,
                              label: patient.bloodGroup!,
                              colors: colors,
                              accentColor: AppColors.doctorGreen,
                            ),
                          if (patient.gender != null &&
                              patient.gender!.isNotEmpty)
                            _InfoChip(
                              icon: SolarLinearIcons.usersGroupRounded,
                              label: patient.gender!,
                              colors: colors,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // HB value
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (patient.currentHemoglobin != null) ...[
                      Text(
                        '${patient.currentHemoglobin}',
                        style: TextStyle(
                          color: _hbColor(patient.currentHemoglobin),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'g/dL',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Icon(
                      SolarLinearIcons.altArrowRight,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),

            // ── Thalassemia Type ──
            if (patient.thalassemiaType != null &&
                patient.thalassemiaType!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.indigo.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  patient.thalassemiaType!,
                  style: const TextStyle(
                    color: AppColors.indigo,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            // ── Transfusion Info Row ──
            if (_hasTransfusionInfo()) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    // Last Transfusion
                    if (patient.lastTransfusionFormatted.isNotEmpty)
                      Expanded(
                        child: _TransfusionInfo(
                          icon: SolarLinearIcons.clockCircle,
                          label: 'Last',
                          value: patient.lastTransfusionFormatted,
                          color: colors.textSecondary,
                          colors: colors,
                        ),
                      ),
                    if (patient.lastTransfusionFormatted.isNotEmpty &&
                        patient.nextTransfusionFormatted.isNotEmpty)
                      Container(
                        width: 1,
                        height: 28,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        color: colors.borderColor,
                      ),
                    // Next Transfusion
                    if (patient.nextTransfusionFormatted.isNotEmpty)
                      Expanded(
                        child: _TransfusionInfo(
                          icon: SolarLinearIcons.calendarMark,
                          label: daysLeft < 0
                              ? 'Overdue'
                              : daysLeft == 0
                                  ? 'Today'
                                  : 'In $daysLeft day${daysLeft == 1 ? '' : 's'}',
                          value: patient.nextTransfusionFormatted,
                          color: daysLeft < 0
                              ? AppColors.error
                              : daysLeft <= 3
                                  ? AppColors.warning
                                  : AppColors.success,
                          colors: colors,
                        ),
                      ),
                  ],
                ),
              ),
            ],

            // ── Phone ──
            if (patient.phone != null && patient.phone!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(SolarLinearIcons.phone,
                      size: 13, color: colors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    patient.phone!,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _hasTransfusionInfo() {
    return patient.lastTransfusionFormatted.isNotEmpty ||
        patient.nextTransfusionFormatted.isNotEmpty;
  }

  Color _hbColor(String? hb) {
    if (hb == null) return AppColors.doctorGreen;
    final val = double.tryParse(hb);
    if (val == null) return AppColors.doctorGreen;
    if (val < 7) return AppColors.error;
    if (val < 9) return AppColors.warning;
    return AppColors.success;
  }
}

// ── Transfusion Info Widget ──

class _TransfusionInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final AppThemeColors colors;

  const _TransfusionInfo({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Info Chip ──

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppThemeColors colors;
  final Color? accentColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.colors,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? colors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
