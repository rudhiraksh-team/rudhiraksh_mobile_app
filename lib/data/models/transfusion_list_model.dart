import 'package:intl/intl.dart';

// Transfusion List Model
class TransfusionResponse {
  final bool success;
  final TransfusionData? data;
  final int count;

  TransfusionResponse({required this.success, this.data, required this.count});

  factory TransfusionResponse.fromJson(Map<String, dynamic> j) {
    return TransfusionResponse(
      success: j['success'] ?? false,
      data: j['data'] != null ? TransfusionData.fromJson(j['data']) : null,
      count: j['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data?.toJson(),
    'count': count,
  };
}

// --- Data Classes ---
class TransfusionData {
  final List<Transfusion> transfusions;
  final DateTime? nextTransfusion;
  final List<MissedTransfusion> missedTransfusions;

  TransfusionData({
    required this.transfusions,
    this.nextTransfusion,
    required this.missedTransfusions,
  });

  factory TransfusionData.fromJson(Map<String, dynamic> j) {
    return TransfusionData(
      transfusions:
          (j['transfusions'] as List<dynamic>?)
              ?.map((e) => Transfusion.fromJson(e))
              .toList() ??
          [],
      nextTransfusion:
          j['next_transfusion'] != null
              ? DateTime.parse(j['next_transfusion']).toLocal()
              : null,
      missedTransfusions:
          (j['missed_transfusions'] as List<dynamic>?)
              ?.map((e) => MissedTransfusion.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'transfusions': transfusions.map((t) => t.toJson()).toList(),
    'next_transfusion': nextTransfusion?.toUtc().toIso8601String(),
    'missed_transfusions': missedTransfusions.map((m) => m.toJson()).toList(),
  };
}

// --- Individual Transfusion Record ---
class Transfusion {
  final int? id;
  final int patientId;
  final DateTime? visitDate;
  final int? bloodbankId;
  final int? attendingStaffUserId;
  final double? preHb;
  final double? patientWeightKg;
  final double? preTempC;
  final int? prePulseBpm;
  final int? preBpSystolic;
  final int? preBpDiastolic;
  final bool? preSymptomsPresent;
  final String? preSymptomsNotes;
  final String? bloodUnitId;
  final String? unitBloodGroup;
  final int? volumeMl;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? transfusionType;
  final bool? crossMatchingDone;
  final bool? preWarmed;
  final bool? consentSigned;
  final double? postTempC;
  final int? postPulseBpm;
  final int? postBpSystolic;
  final int? postBpDiastolic;
  final String? reactionSeverity;
  final String? reactionNotes;
  final String? reactionTreatment;
  final bool? medicationGiven;
  final String? medications;
  final String? notes;
  final DateTime? nextTransfusionDate;
  final String? recommendedLabTests;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final AttendingStaff? attendingStaff;
  final bool isSyntheticMissed;

  final String? bloodBagType;

  Transfusion({
    required this.id,
    required this.patientId,
    this.visitDate,
    this.bloodbankId,
    this.attendingStaffUserId,
    this.preHb,
    this.patientWeightKg,
    this.preTempC,
    this.prePulseBpm,
    this.preBpSystolic,
    this.preBpDiastolic,
    this.preSymptomsPresent,
    this.preSymptomsNotes,
    this.bloodUnitId,
    this.unitBloodGroup,
    this.volumeMl,
    this.startTime,
    this.endTime,
    this.transfusionType,
    this.crossMatchingDone,
    this.preWarmed,
    this.consentSigned,
    this.postTempC,
    this.postPulseBpm,
    this.postBpSystolic,
    this.postBpDiastolic,
    this.reactionSeverity,
    this.reactionNotes,
    this.reactionTreatment,
    this.medicationGiven,
    required this.medications,
    this.notes = '',
    this.nextTransfusionDate,
    this.recommendedLabTests,
    this.createdAt,
    this.updatedAt,
    this.attendingStaff,
    this.isSyntheticMissed = false,
    this.bloodBagType,
  });

  factory Transfusion.fromJson(Map<String, dynamic> j) {
    DateTime? parse(String? s) =>
        s != null ? DateTime.parse(s).toLocal() : null;
    String? str(dynamic v) => v?.toString();

    return Transfusion(
      id: j['id'],
      patientId: j['patient_id'],
      visitDate: parse(j['visit_date']),
      bloodbankId: j['bloodbank_id'],
      attendingStaffUserId: j['attending_staff_user_id'],
      preHb:
          j['pre_hb_g_dl'] != null
              ? (j['pre_hb_g_dl'] as num).toDouble()
              : null,
      patientWeightKg:
          j['patient_weight_kg'] != null
              ? (j['patient_weight_kg'] as num).toDouble()
              : null,
      preTempC:
          j['pre_temp_c'] != null ? (j['pre_temp_c'] as num).toDouble() : null,
      prePulseBpm: j['pre_pulse_bpm'],
      preBpSystolic: j['pre_bp_systolic'],
      preBpDiastolic: j['pre_bp_diastolic'],
      preSymptomsPresent: j['pre_symptoms_present'],
      preSymptomsNotes: str(j['pre_symptoms_notes']),
      bloodUnitId: j['blood_unit_id'],
      unitBloodGroup: j['unit_blood_group'],
      volumeMl: j['volume_ml'],
      startTime: parse(j['start_time']),
      endTime: parse(j['end_time']),
      transfusionType: j['transfusion_type'],
      crossMatchingDone: j['cross_matching_done'],
      preWarmed: j['pre_warmed'],
      consentSigned: j['consent_signed'],
      postTempC:
          j['post_temp_c'] != null
              ? (j['post_temp_c'] as num).toDouble()
              : null,
      postPulseBpm: j['post_pulse_bpm'],
      postBpSystolic: j['post_bp_systolic'],
      postBpDiastolic: j['post_bp_diastolic'],
      reactionSeverity: j['reaction_severity'],
      reactionNotes: str(j['reaction_notes']),
      reactionTreatment: str(j['reaction_treatment']),
      medicationGiven: j['medication_given'],
      medications: str(j['medications']),

      notes: j['notes'],
      nextTransfusionDate: parse(j['next_transfusion_date']),
      recommendedLabTests: j['recommended_lab_tests'],
      createdAt: parse(j['created_at']),
      updatedAt: parse(j['updated_at']),
      attendingStaff:
          j['attending_staff'] != null
              ? AttendingStaff.fromJson(j['attending_staff'])
              : null,
      bloodBagType: str(
        j['blood_bag_type'] ?? j['bloodbagtype'] ?? j['bloodbgtype'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patient_id': patientId,
    'visit_date': visitDate?.toUtc().toIso8601String(),
    'bloodbank_id': bloodbankId,
    'attending_staff_user_id': attendingStaffUserId,
    'pre_hb_g_dl': preHb,
    'patient_weight_kg': patientWeightKg,
    'pre_temp_c': preTempC,
    'pre_pulse_bpm': prePulseBpm,
    'pre_bp_systolic': preBpSystolic,
    'pre_bp_diastolic': preBpDiastolic,
    'pre_symptoms_present': preSymptomsPresent,
    'pre_symptoms_notes': preSymptomsNotes,
    'blood_unit_id': bloodUnitId,
    'unit_blood_group': unitBloodGroup,
    'volume_ml': volumeMl,
    'start_time': startTime?.toUtc().toIso8601String(),
    'end_time': endTime?.toUtc().toIso8601String(),
    'transfusion_type': transfusionType,
    'cross_matching_done': crossMatchingDone,
    'pre_warmed': preWarmed,
    'consent_signed': consentSigned,
    'post_temp_c': postTempC,
    'post_pulse_bpm': postPulseBpm,
    'post_bp_systolic': postBpSystolic,
    'post_bp_diastolic': postBpDiastolic,
    'reaction_severity': reactionSeverity,
    'reaction_notes': reactionNotes,
    'reaction_treatment': reactionTreatment,
    'medication_given': medicationGiven,
    'medications': medications,
    'notes': notes,
    'next_transfusion_date': nextTransfusionDate?.toUtc().toIso8601String(),
    'recommended_lab_tests': recommendedLabTests,
    'created_at': createdAt?.toUtc().toIso8601String(),
    'updated_at': updatedAt?.toUtc().toIso8601String(),
    'attending_staff': attendingStaff?.toJson(),
    'blood_bag_type': bloodBagType,
  };

  // --- Formatting helpers (use these in UI) ---
  String formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  String formatDate(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('dd MMM yyyy').format(dt);
  }

  String get visitDateFormatted => formatDateTime(visitDate);
  String get startTimeFormatted => formatDateTime(startTime);
  String get endTimeFormatted => formatDateTime(endTime);
  String get nextTransfusionFormatted => formatDate(nextTransfusionDate);
  String get createdAtFormatted => formatDateTime(createdAt);
  String get updatedAtFormatted => formatDateTime(updatedAt);

  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (nextTransfusionDate == null) return 0;
    final compareDate = DateTime(
      nextTransfusionDate!.year,
      nextTransfusionDate!.month,
      nextTransfusionDate!.day,
    );
    return compareDate.difference(today).inDays;
  }

  // helper for BP display
  String get preBpFormatted {
    final s = preBpSystolic?.toString() ?? '-';
    final d = preBpDiastolic?.toString() ?? '-';
    return '$s / $d mmHg';
  }

  String get postBpFormatted {
    final s = postBpSystolic?.toString() ?? '-';
    final d = postBpDiastolic?.toString() ?? '-';
    return '$s / $d mmHg';
  }
}

class AttendingStaff {
  final String? fullName;

  AttendingStaff({this.fullName});

  factory AttendingStaff.fromJson(Map<String, dynamic> j) =>
      AttendingStaff(fullName: j['full_name']);

  Map<String, dynamic> toJson() => {'full_name': fullName};
}

class MissedTransfusion {
  final DateTime? expectedDate;

  MissedTransfusion({this.expectedDate});

  factory MissedTransfusion.fromJson(Map<String, dynamic> j) {
    return MissedTransfusion(
      expectedDate:
          j['expected_date'] != null
              ? DateTime.parse(j['expected_date']).toLocal()
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'expected_date': expectedDate?.toUtc().toIso8601String(),
  };

  String get expectedDateFormatted =>
      expectedDate == null
          ? '-'
          : DateFormat('dd MMM yyyy').format(expectedDate!);
}
