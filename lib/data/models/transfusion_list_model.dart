import 'package:intl/intl.dart';

// Transfusion List Model
class TransfusionResponse {
  final bool success;
  final TransfusionData? data;
  final int count;

  TransfusionResponse({required this.success, this.data, required this.count});

  factory TransfusionResponse.fromJson(Map<String, dynamic> j) {
    TransfusionData? data;
    if (j['data'] != null) {
      if (j['data'] is List) {
        // API returns paginated: { data: [...], pagination: {...} }
        data = TransfusionData(
          transfusions: (j['data'] as List)
              .map((e) => Transfusion.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
          missedTransfusions: [],
        );
      } else {
        data = TransfusionData.fromJson(j['data']);
      }
    }
    return TransfusionResponse(
      success: j['success'] ?? false,
      data: data,
      count: j['pagination']?['total'] ?? j['count'] ?? 0,
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
              ?.map((e) => Transfusion.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      nextTransfusion:
          j['next_transfusion'] != null
              ? DateTime.tryParse(j['next_transfusion'].toString())?.toLocal()
              : null,
      missedTransfusions:
          (j['missed_transfusions'] as List<dynamic>?)
              ?.map((e) => MissedTransfusion.fromJson(Map<String, dynamic>.from(e)))
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
    DateTime? parse(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      return DateTime.tryParse(s)?.toLocal();
    }
    String? str(dynamic v) => v?.toString();
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString().split('.').first);
    }
    // Extract .value from enum relation objects or return string as-is
    String? enumVal(dynamic v) {
      if (v == null) return null;
      if (v is Map) return v['value']?.toString() ?? v['label']?.toString();
      return v.toString();
    }

    return Transfusion(
      id: toInt(j['id']),
      patientId: toInt(j['patient_id'] ?? j['patientId']) ?? 0,
      visitDate: parse(j['visit_date'] ?? j['transfusion_date'] ?? j['transfusionDate']),
      bloodbankId: toInt(j['bloodbank_id'] ?? j['blood_bank_id'] ?? j['bloodBankId']),
      attendingStaffUserId: toInt(j['attending_staff_user_id'] ?? j['performed_by_id'] ?? j['performedById']),
      preHb: toDouble(j['pre_hb_g_dl'] ?? j['pre_hemoglobin'] ?? j['preHemoglobin']),
      patientWeightKg: toDouble(j['patient_weight_kg'] ?? j['patientWeightKg']),
      preTempC: toDouble(j['pre_temp_c'] ?? j['preTempC']),
      prePulseBpm: toInt(j['pre_pulse_bpm'] ?? j['prePulseBpm']),
      preBpSystolic: toInt(j['pre_bp_systolic'] ?? j['preBpSystolic']),
      preBpDiastolic: toInt(j['pre_bp_diastolic'] ?? j['preBpDiastolic']),
      preSymptomsPresent: j['pre_symptoms_present'] ?? j['preSymptomsPresent'],
      preSymptomsNotes: str(j['pre_symptoms_notes'] ?? j['preSymptomsNotes']),
      bloodUnitId: str(j['blood_unit_id'] ?? j['blood_bag_number'] ?? j['bloodBagNumber']),
      unitBloodGroup: str(j['unit_blood_group'] ?? j['donor_blood_group'] ?? j['donorBloodGroup']),
      volumeMl: toInt(j['volume_ml'] ?? j['units_transfused'] ?? j['unitsTransfused']),
      startTime: parse(j['start_time'] ?? j['startTime']),
      endTime: parse(j['end_time'] ?? j['endTime']),
      transfusionType: enumVal(j['transfusion_type'] ?? j['transfusionType']),
      crossMatchingDone: j['cross_matching_done'] ?? j['crossMatchingDone'],
      preWarmed: j['pre_warmed'] ?? j['preWarmed'],
      consentSigned: j['consent_signed'] ?? j['consentSigned'],
      postTempC: toDouble(j['post_temp_c'] ?? j['postTempC']),
      postPulseBpm: toInt(j['post_pulse_bpm'] ?? j['postPulseBpm']),
      postBpSystolic: toInt(j['post_bp_systolic'] ?? j['postBpSystolic']),
      postBpDiastolic: toInt(j['post_bp_diastolic'] ?? j['postBpDiastolic']),
      reactionSeverity: enumVal(j['reaction_severity'] ?? j['reactionSeverity']),
      reactionNotes: str(j['reaction_notes'] ?? j['reaction_details'] ?? j['reactionDetails']),
      reactionTreatment: str(j['reaction_treatment'] ?? j['reactionTreatment']),
      medicationGiven: j['medication_given'] ?? j['medicationGiven'],
      medications: str(j['medications']),
      notes: str(j['notes']),
      nextTransfusionDate: parse(j['next_transfusion_date'] ?? j['next_scheduled_date'] ?? j['nextScheduledDate']),
      recommendedLabTests: str(j['recommended_lab_tests'] ?? j['recommendedLabTests']),
      createdAt: parse(j['created_at'] ?? j['createdAt']),
      updatedAt: parse(j['updated_at'] ?? j['updatedAt']),
      attendingStaff:
          (j['attending_staff'] ?? j['performedBy']) != null
              ? AttendingStaff.fromJson(Map<String, dynamic>.from(j['attending_staff'] ?? j['performedBy']))
              : null,
      bloodBagType: str(
        j['blood_bag_type'] ?? j['bloodbagtype'] ?? j['bloodbgtype'] ?? j['bloodBagType'],
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
      AttendingStaff(fullName: j['full_name'] ?? j['fullName'] ?? j['name'] ?? j['email']);

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
