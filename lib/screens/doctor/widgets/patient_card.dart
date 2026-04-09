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
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.brandCrimson.withValues(alpha: 0.1),
              child: Text(
                patient.initials,
                style: const TextStyle(
                  color: AppColors.brandCrimson,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (patient.age.isNotEmpty) ...[
                        _InfoChip(
                          icon: SolarLinearIcons.userRounded,
                          label: patient.age,
                          colors: colors,
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (patient.bloodGroup != null && patient.bloodGroup!.isNotEmpty)
                        _InfoChip(
                          icon: SolarLinearIcons.waterdrop,
                          label: patient.bloodGroup!,
                          colors: colors,
                          accentColor: AppColors.brandRed,
                        ),
                    ],
                  ),
                  if (patient.thalassemiaType != null && patient.thalassemiaType!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      patient.thalassemiaType!,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // HB value + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (patient.currentHemoglobin != null) ...[
                  Text(
                    '${patient.currentHemoglobin}',
                    style: const TextStyle(
                      color: AppColors.brandCrimson,
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
                const SizedBox(height: 4),
                Icon(
                  SolarLinearIcons.altArrowRight,
                  size: 16,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
