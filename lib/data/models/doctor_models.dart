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
  final String? thalassemiaPatientId;
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
    this.thalassemiaPatientId,
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
      thalassemiaPatientId: patient['thalassemia_user_id'] ?? patient['thalassemiaUserId'] ??
          patient['thalassemia_patient_id'] ?? patient['thalassemiaPatientId'],
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
  final DateTime? dueDate;
  final String? notes;
  final String? requestedByName;
  final DateTime? createdAt;
  // Linked document (set when patient uploads the report).
  final String? documentFileUrl;
  final String? documentFileName;

  LabRequest({
    required this.id,
    required this.testName,
    required this.status,
    this.labName,
    this.testDate,
    this.dueDate,
    this.notes,
    this.requestedByName,
    this.createdAt,
    this.documentFileUrl,
    this.documentFileName,
  });

  factory LabRequest.fromJson(Map<String, dynamic> json) {
    final requestedBy = json['requestedBy'];
    final document = json['document'];
    return LabRequest(
      id: json['id'] ?? 0,
      testName: json['testName'] ?? '',
      status: json['status'] ?? 'requested',
      labName: json['labName'],
      testDate: json['testDate'],
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      notes: json['notes'],
      requestedByName: requestedBy?['name'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      documentFileUrl: document?['fileUrl'],
      documentFileName: document?['fileName'],
    );
  }

  String get formattedDate {
    if (createdAt == null) return '';
    return DateFormat('dd MMM yyyy').format(createdAt!);
  }

  String? get formattedDueDate {
    if (dueDate == null) return null;
    return DateFormat('dd MMM yyyy').format(dueDate!);
  }

  /// True when the patient has not yet uploaded a report and the due date
  /// is strictly before today. Used by the UI to flag overdue items in
  /// red.
  bool get isOverdue {
    if (dueDate == null) return false;
    if (status != 'requested') return false;
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return dueDate!.isBefore(startOfToday);
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

/// Ferritin history entry
class FerritinEntry {
  final int id;
  final DateTime? date;
  final double? ferritinValue;
  final String? notes;

  FerritinEntry({
    required this.id,
    this.date,
    this.ferritinValue,
    this.notes,
  });

  factory FerritinEntry.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }
    return FerritinEntry(
      id: json['id'] ?? 0,
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
      ferritinValue: toDouble(json['ferritinValue'] ?? json['value']),
      notes: json['notes'],
    );
  }

  String get formattedDate => date == null ? '' : DateFormat('dd MMM yyyy').format(date!);
}

/// Chelation therapy history entry
class ChelationEntry {
  final int id;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? medication;
  final String? dosage;
  final String? notes;

  ChelationEntry({
    required this.id,
    this.startDate,
    this.endDate,
    this.medication,
    this.dosage,
    this.notes,
  });

  factory ChelationEntry.fromJson(Map<String, dynamic> json) {
    return ChelationEntry(
      id: json['id'] ?? 0,
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'].toString()) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'].toString()) : null,
      medication: json['medication']?.toString(),
      dosage: json['dosage']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  String formatDate(DateTime? d) => d == null ? '—' : DateFormat('dd MMM yyyy').format(d);
  String get startFormatted => formatDate(startDate);
  String get endFormatted => formatDate(endDate);
}

/// Patient image (e.g. clinical photo, scan)
class PatientImage {
  final int id;
  final String imageUrl;
  final String? caption;
  final DateTime? createdAt;

  PatientImage({
    required this.id,
    required this.imageUrl,
    this.caption,
    this.createdAt,
  });

  factory PatientImage.fromJson(Map<String, dynamic> json) {
    return PatientImage(
      id: json['id'] ?? 0,
      imageUrl: (json['imageUrl'] ?? json['fileUrl'] ?? '').toString(),
      caption: json['caption']?.toString() ?? json['notes']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  String get formattedDate => createdAt == null ? '' : DateFormat('dd MMM yyyy').format(createdAt!);
}
