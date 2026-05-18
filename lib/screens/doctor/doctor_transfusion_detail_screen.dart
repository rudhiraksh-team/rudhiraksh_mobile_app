import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/core/widgets/custom_back_button.dart';
import 'package:rudhirakshapp/data/models/transfusion_list_model.dart';

class DoctorTransfusionDetailScreen extends StatelessWidget {
  const DoctorTransfusionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Transfusion record = Get.arguments as Transfusion;
    final colors = AppThemeColors.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: colors.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const CustomBackButton(),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              SolarLinearIcons.documentText,
              color: AppColors.doctorGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Transfusion Details',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.05,
          12,
          screenWidth * 0.05,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Card ──
            _buildHeaderCard(record, colors),
            const SizedBox(height: 14),

            // ── Vitals ──
            _buildVitalsCard(record, colors),
            const SizedBox(height: 12),

            // ── Blood Unit + Timeline Row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildBloodUnitCard(record, colors)),
                const SizedBox(width: 12),
                Expanded(child: _buildTimelineCard(record, colors)),
              ],
            ),
            const SizedBox(height: 12),

            // ── Safety Checks ──
            _buildSafetyChecksCard(record, colors),

            // ── Reactions ──
            if (_hasReactions(record)) ...[
              const SizedBox(height: 12),
              _buildReactionsCard(record, colors),
            ],

            // ── Medications ──
            if (record.medicationGiven == true ||
                (record.medications != null &&
                    record.medications!.isNotEmpty)) ...[
              const SizedBox(height: 12),
              _sectionCard(
                colors,
                SolarLinearIcons.pill,
                'Medications',
                AppColors.amber,
                child: Text(
                  record.medications ?? 'Not specified',
                  style: TextStyle(color: colors.textPrimary, fontSize: 13),
                ),
              ),
            ],

            // ── Pre-Symptoms ──
            if (record.preSymptomsPresent == true &&
                record.preSymptomsNotes != null) ...[
              const SizedBox(height: 12),
              _sectionCard(
                colors,
                SolarLinearIcons.notes,
                'Pre-Symptoms',
                AppColors.orange,
                child: Text(
                  record.preSymptomsNotes!,
                  style: TextStyle(color: colors.textPrimary, fontSize: 13),
                ),
              ),
            ],

            // ── Lab Tests ──
            if (record.recommendedLabTests != null &&
                record.recommendedLabTests!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _sectionCard(
                colors,
                SolarLinearIcons.stethoscope,
                'Recommended Lab Tests',
                AppColors.indigo,
                child: Text(
                  record.recommendedLabTests!,
                  style: TextStyle(color: colors.textPrimary, fontSize: 13),
                ),
              ),
            ],

            // ── Notes ──
            if (_hasNotes(record)) ...[
              const SizedBox(height: 12),
              _sectionCard(
                colors,
                SolarLinearIcons.documentText,
                'Notes',
                AppColors.sky,
                child: Text(
                  record.notes!
                      .replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '')
                      .trim(),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],

            // ── Next Transfusion ──
            if (record.nextTransfusionDate != null) ...[
              const SizedBox(height: 12),
              _sectionCard(
                colors,
                SolarLinearIcons.calendarMark,
                'Next Transfusion',
                AppColors.transfusionAccent,
                child: Text(
                  record.nextTransfusionFormatted,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Header Card ──

  Widget _buildHeaderCard(Transfusion record, AppThemeColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(SolarLinearIcons.checkCircle,
                      color: AppColors.success, size: 16),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Completed',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (record.unitBloodGroup != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.unitBloodGroup!,
                    style: const TextStyle(
                      color: AppColors.coral,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (record.transfusionType != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.transfusionType!,
                    style: const TextStyle(
                      color: AppColors.info,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (record.id != null)
                Text(
                  '#${record.id}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            record.visitDateFormatted,
            style: TextStyle(
              fontSize: 22,
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          if (record.attendingStaff?.fullName != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(SolarLinearIcons.stethoscope,
                    size: 15, color: colors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Dr. ${record.attendingStaff!.fullName}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Vitals Card ──

  Widget _buildVitalsCard(Transfusion record, AppThemeColors colors) {
    return _sectionCard(
      colors,
      SolarLinearIcons.heartPulse,
      'Vitals',
      AppColors.coral,
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 100),
              Expanded(
                child: Text(
                  'Pre',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.transfusionAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Post',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.historyAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _vitalRow(colors, 'Hemoglobin',
              record.preHb?.toStringAsFixed(1) ?? '-', '-'),
          _vitalRow(colors, 'Temp (\u00b0C)',
              record.preTempC?.toString() ?? '-',
              record.postTempC?.toString() ?? '-'),
          _vitalRow(colors, 'Pulse (bpm)',
              record.prePulseBpm?.toString() ?? '-',
              record.postPulseBpm?.toString() ?? '-'),
          _vitalRow(
              colors, 'BP', record.preBpFormatted, record.postBpFormatted),
          if (record.patientWeightKg != null)
            _vitalRow(colors, 'Weight (kg)',
                record.patientWeightKg.toString(), '-'),
        ],
      ),
    );
  }

  // ── Blood Unit Card ──

  Widget _buildBloodUnitCard(Transfusion record, AppThemeColors colors) {
    return _sectionCard(
      colors,
      SolarLinearIcons.bagHeart,
      'Blood Unit',
      AppColors.rose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kvCompact(colors, 'Group', record.unitBloodGroup ?? '-'),
          _kvCompact(colors, 'Volume', '${record.volumeMl ?? '-'} ml'),
          _kvCompact(colors, 'Type', record.transfusionType ?? '-'),
          _kvCompact(colors, 'Bag', record.bloodBagType ?? '-'),
          if (record.bloodUnitId != null)
            _kvCompact(colors, 'Unit ID', record.bloodUnitId!),
        ],
      ),
    );
  }

  // ── Timeline Card ──

  Widget _buildTimelineCard(Transfusion record, AppThemeColors colors) {
    return _sectionCard(
      colors,
      SolarLinearIcons.clockCircle,
      'Timeline',
      AppColors.sky,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kvCompact(colors, 'Start', record.startTimeFormatted),
          _kvCompact(colors, 'End', record.endTimeFormatted),
        ],
      ),
    );
  }

  // ── Safety Checks Card ──

  Widget _buildSafetyChecksCard(Transfusion record, AppThemeColors colors) {
    return _sectionCard(
      colors,
      SolarLinearIcons.shieldCheck,
      'Safety Checks',
      AppColors.emerald,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _boolChip(colors, 'Cross-match', record.crossMatchingDone),
          _boolChip(colors, 'Pre-warmed', record.preWarmed),
          _boolChip(colors, 'Consent', record.consentSigned),
        ],
      ),
    );
  }

  // ── Reactions Card ──

  Widget _buildReactionsCard(Transfusion record, AppThemeColors colors) {
    return _sectionCard(
      colors,
      SolarLinearIcons.shieldWarning,
      'Reactions',
      AppColors.error,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (record.reactionSeverity != null)
            _kvCompact(colors, 'Severity', record.reactionSeverity!),
          if (record.reactionNotes != null)
            _kvCompact(colors, 'Notes', record.reactionNotes!),
          if (record.reactionTreatment != null)
            _kvCompact(colors, 'Treatment', record.reactionTreatment!),
        ],
      ),
    );
  }

  // ── Shared Helpers ──

  bool _hasReactions(Transfusion record) {
    return (record.reactionSeverity != null &&
            record.reactionSeverity!.isNotEmpty) ||
        (record.reactionNotes != null && record.reactionNotes!.isNotEmpty) ||
        (record.reactionTreatment != null &&
            record.reactionTreatment!.isNotEmpty);
  }

  bool _hasNotes(Transfusion record) {
    return record.notes != null &&
        record.notes!
            .replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '')
            .trim()
            .isNotEmpty;
  }

  Widget _sectionCard(
    AppThemeColors colors,
    IconData icon,
    String title,
    Color accent, {
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: accent),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _vitalRow(
      AppThemeColors colors, String label, String pre, String post) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              pre,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              post,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kvCompact(AppThemeColors colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _boolChip(AppThemeColors colors, String label, bool? value) {
    final isYes = value == true;
    final color = value == null
        ? colors.textSecondary
        : isYes
            ? AppColors.success
            : AppColors.error;
    final text = value == null ? 'N/A' : (isYes ? 'Yes' : 'No');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
