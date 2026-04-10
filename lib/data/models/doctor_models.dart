import 'package:intl/intl.dart';

/// Patient assigned to a doctor via patient_assignments
class AssignedPatient {
  final int id;
  final int patientId;
  final Map<String, dynamic> patientData;

  // Parsed patient fields
  final String name;
  final String? dateOfBirth;
  final String? bloodGroup;
  final String? thalassemiaType;
  final String? currentHemoglobin;
  final String? lastTransfusionDate;
  final String? nextTransfusionDate;
  final String? profileImageUrl;
  final String? phone;
  final String? email;
  final String? gender;
  final String? status;

  AssignedPatient({
    required this.id,
    required this.patientId,
    required this.patientData,
    required this.name,
    this.dateOfBirth,
    this.bloodGroup,
    this.thalassemiaType,
    this.currentHemoglobin,
    this.lastTransfusionDate,
    this.nextTransfusionDate,
    this.profileImageUrl,
    this.phone,
    this.email,
    this.gender,
    this.status,
  });

  factory AssignedPatient.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'] ?? {};

    String enumLabel(dynamic field) {
      if (field == null) return '';
      if (field is String) return field;
      if (field is Map) return field['label'] ?? field['value'] ?? '';
      return '';
    }

    final firstName = patient['first_name'] ?? patient['name'] ?? '';
    final middleName = patient['middle_name'] ?? '';
    final surname = patient['surname'] ?? '';
    final fullName = patient['full_name'] ??
        [firstName, middleName, surname]
            .where((s) => s.toString().isNotEmpty)
            .join(' ');

    return AssignedPatient(
      id: json['id'] ?? 0,
      patientId: json['patientId'] ?? patient['id'] ?? 0,
      patientData: Map<String, dynamic>.from(patient),
      name: fullName,
      dateOfBirth: patient['date_of_birth'],
      bloodGroup: enumLabel(patient['bloodGroup'] ?? patient['blood_group']),
      thalassemiaType: enumLabel(patient['thalassemiaType'] ?? patient['thalassemia_type']),
      currentHemoglobin: patient['current_hemoglobin']?.toString(),
      lastTransfusionDate: patient['last_transfusion_date'],
      nextTransfusionDate: patient['next_transfusion_date'],
      profileImageUrl: patient['profile_image_url'] ?? patient['profileImageUrl'],
      phone: patient['phone'],
      email: patient['email'],
      gender: enumLabel(patient['gender']),
      status: enumLabel(patient['status']),
    );
  }

  String get age {
    if (dateOfBirth == null || dateOfBirth!.isEmpty) return '';
    try {
      final dob = DateTime.parse(dateOfBirth!);
      final now = DateTime.now();
      int years = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        years--;
      }
      return '$years yrs';
    } catch (_) {
      return '';
    }
  }

  String get initials {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  String get nextTransfusionFormatted {
    if (nextTransfusionDate == null || nextTransfusionDate!.isEmpty) return '';
    try {
      final dt = DateTime.parse(nextTransfusionDate!);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return '';
    }
  }

  String get lastTransfusionFormatted {
    if (lastTransfusionDate == null || lastTransfusionDate!.isEmpty) return '';
    try {
      final dt = DateTime.parse(lastTransfusionDate!);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return '';
    }
  }

  int get daysUntilNextTransfusion {
    if (nextTransfusionDate == null || nextTransfusionDate!.isEmpty) return -1;
    try {
      final dt = DateTime.parse(nextTransfusionDate!);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(dt.year, dt.month, dt.day);
      return target.difference(today).inDays;
    } catch (_) {
      return -1;
    }
  }
}

/// Growth entry for patient growth charts
class GrowthEntry {
  final int id;
  final String date;
  final double? heightCm;
  final double? weightKg;
  final double? bmi;
  final double? hbValue;
  final String? notes;

  GrowthEntry({
    required this.id,
    required this.date,
    this.heightCm,
    this.weightKg,
    this.bmi,
    this.hbValue,
    this.notes,
  });

  factory GrowthEntry.fromJson(Map<String, dynamic> json) {
    return GrowthEntry(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      heightCm: json['heightCm'] != null ? double.tryParse(json['heightCm'].toString()) : null,
      weightKg: json['weightKg'] != null ? double.tryParse(json['weightKg'].toString()) : null,
      bmi: json['bmi'] != null ? double.tryParse(json['bmi'].toString()) : null,
      hbValue: json['hbValue'] != null ? double.tryParse(json['hbValue'].toString()) : null,
      notes: json['notes'],
    );
  }

  DateTime? get parsedDate {
    try {
      return DateTime.parse(date);
    } catch (_) {
      return null;
    }
  }

  String get formattedDate {
    final dt = parsedDate;
    if (dt == null) return date;
    return DateFormat('dd MMM yyyy').format(dt);
  }
}

/// Document uploaded by patient or blood bank
class PatientDocument {
  final int id;
  final String? documentType;
  final String fileUrl;
  final String? fileName;
  final bool reviewedStatus;
  final String? notes;
  final String? uploadedByName;
  final DateTime? createdAt;

  PatientDocument({
    required this.id,
    this.documentType,
    required this.fileUrl,
    this.fileName,
    this.reviewedStatus = false,
    this.notes,
    this.uploadedByName,
    this.createdAt,
  });

  factory PatientDocument.fromJson(Map<String, dynamic> json) {
    final uploadedBy = json['uploadedBy'];
    return PatientDocument(
      id: json['id'] ?? 0,
      documentType: json['documentType'],
      fileUrl: json['fileUrl'] ?? '',
      fileName: json['fileName'],
      reviewedStatus: json['reviewedStatus'] ?? false,
      notes: json['notes'],
      uploadedByName: uploadedBy?['name'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  String get formattedDate {
    if (createdAt == null) return '';
    return DateFormat('dd MMM yyyy').format(createdAt!);
  }
}

/// Lab request / report request
class LabRequest {
  final int id;
  final String testName;
  final String status;
  final String? labName;
  final String? testDate;
  final String? notes;
  final String? requestedByName;
  final DateTime? createdAt;

  LabRequest({
    required this.id,
    required this.testName,
    required this.status,
    this.labName,
    this.testDate,
    this.notes,
    this.requestedByName,
    this.createdAt,
  });

  factory LabRequest.fromJson(Map<String, dynamic> json) {
    final requestedBy = json['requestedBy'];
    return LabRequest(
      id: json['id'] ?? 0,
      testName: json['testName'] ?? '',
      status: json['status'] ?? 'requested',
      labName: json['labName'],
      testDate: json['testDate'],
      notes: json['notes'],
      requestedByName: requestedBy?['name'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  String get formattedDate {
    if (createdAt == null) return '';
    return DateFormat('dd MMM yyyy').format(createdAt!);
  }

  String get statusLabel {
    switch (status) {
      case 'requested':
        return 'Requested';
      case 'uploaded':
        return 'Uploaded';
      case 'reviewed':
        return 'Reviewed';
      default:
        return status;
    }
  }
}
