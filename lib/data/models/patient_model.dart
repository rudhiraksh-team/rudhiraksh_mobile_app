class Patient {
  final int id;
  final int bloodbankId;
  final String firstName;
  final String? middleName;
  final String surname;
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final String phoneNumber;
  final String email;
  final String addressStreet;
  final String addressArea;
  final String addressCity;
  final String addressState;
  final String addressPincode;
  final String bloodGroup;
  final String thalassemiaType;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String? emergencyContactName2;
  final String? emergencyContactPhone2;
  // New SaaS fields
  final String? abhaId;
  final String? thalassemiaPatientId;
  final String? patientStatus; // active, inactive, deceased
  final String? diagnosisDate;
  final double? ferritinLevel;
  final int? assignedDoctorId;
  final String? assignedDoctorName;
  // Clinical flags
  final bool? cardiacComplication;
  final bool? liverEnlargement;
  final bool? endocrineDisorder;
  final bool? alloantibodyPresent;
  final bool? recurrentReactionFlag;
  // Profile
  final String? profilePhotoUrl;
  final int? userId;

  Patient({
    required this.id,
    required this.bloodbankId,
    this.firstName = '',
    this.middleName,
    this.surname = '',
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.phoneNumber,
    required this.email,
    required this.addressStreet,
    required this.addressArea,
    required this.addressCity,
    required this.addressState,
    required this.addressPincode,
    required this.bloodGroup,
    required this.thalassemiaType,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    this.emergencyContactName2,
    this.emergencyContactPhone2,
    this.abhaId,
    this.thalassemiaPatientId,
    this.patientStatus,
    this.diagnosisDate,
    this.ferritinLevel,
    this.assignedDoctorId,
    this.assignedDoctorName,
    this.cardiacComplication,
    this.liverEnlargement,
    this.endocrineDisorder,
    this.alloantibodyPresent,
    this.recurrentReactionFlag,
    this.profilePhotoUrl,
    this.userId,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data == null) {
      throw Exception("Patient data is missing");
    }

    // Support both { data: { patient: {...} } } and { data: {...patientFields} }
    final patient = data['patient'] ?? data;

    // Build full name from parts if available
    final firstName = patient['first_name'] ?? patient['firstName'] ?? patient['name'] ?? '';
    final middleName = patient['middle_name'] ?? patient['middleName'];
    final surname = patient['surname'] ?? patient['last_name'] ?? patient['lastName'] ?? '';
    final fullName = patient['full_name'] ?? patient['fullName'] ??
        [firstName, middleName, surname].where((s) => s != null && s.toString().isNotEmpty).join(' ');

    // Helper to extract label/value from enum relation objects or plain strings
    String enumLabel(dynamic field, [String fallback = '']) {
      if (field == null) return fallback;
      if (field is String) return field;
      if (field is Map) return field['label'] ?? field['value'] ?? fallback;
      return fallback;
    }

    return Patient(
      id: patient['id'] ?? 0,
      bloodbankId: patient['bloodbank_id'] ?? patient['bloodBankId'] ?? patient['bloodBank']?['id'] ?? 0,
      firstName: firstName,
      middleName: middleName,
      surname: surname,
      fullName: fullName,
      dateOfBirth: patient['date_of_birth'] ?? patient['dateOfBirth'] ?? '',
      gender: enumLabel(patient['gender']),
      phoneNumber: patient['phone'] ?? patient['phone_number'] ?? patient['phoneNumber'] ?? '',
      email: patient['email'] ?? '',
      addressStreet: patient['address_street'] ?? patient['addressStreet'] ?? patient['street'] ?? '',
      addressArea: patient['address_area'] ?? patient['addressArea'] ?? patient['address'] ?? patient['area'] ?? '',
      addressCity: patient['address_city'] ?? patient['addressCity'] ?? patient['city'] ?? '',
      addressState: patient['address_state'] ?? patient['addressState'] ?? patient['state'] ?? '',
      addressPincode: patient['address_pincode'] ?? patient['addressPincode'] ?? patient['pincode'] ?? patient['pinCode'] ?? '',
      bloodGroup: enumLabel(patient['blood_group'] ?? patient['bloodGroup']),
      thalassemiaType: enumLabel(patient['thalassemia_type'] ?? patient['thalassemiaType']),
      emergencyContactName: patient['emergencyContactName'] ?? patient['emergency_contact_name'] ?? '',
      emergencyContactPhone: patient['emergencyContactPhone'] ?? patient['emergency_contact_phone'] ?? '',
      emergencyContactName2: patient['emergencyContactName2'] ?? patient['emergency_contact_name_2'],
      emergencyContactPhone2: patient['emergencyContactPhone2'] ?? patient['emergency_contact_phone_2'],
      abhaId: patient['abha_id'] ?? patient['abhaId'],
      thalassemiaPatientId: patient['thalassemia_patient_id'] ?? patient['thalassemiaPatientId'] ?? patient['thalassemia_user_id'] ?? patient['thalassemiaUserId'],
      patientStatus: enumLabel(patient['status'] ?? patient['patientStatus'], 'active'),
      diagnosisDate: patient['diagnosis_date'] ?? patient['diagnosisDate'],
      ferritinLevel: patient['ferritin_level'] != null
          ? double.tryParse(patient['ferritin_level'].toString())
          : (patient['ferritinLevel'] != null ? double.tryParse(patient['ferritinLevel'].toString()) : null),
      assignedDoctorId: patient['assigned_doctor_id'] ?? patient['assignedDoctorId'],
      assignedDoctorName: patient['assigned_doctor_name'] ?? patient['assignedDoctorName'],
      cardiacComplication: patient['cardiac_complication'] ?? patient['cardiacComplication'],
      liverEnlargement: patient['liver_enlargement'] ?? patient['liverEnlargement'],
      endocrineDisorder: patient['endocrine_disorder'] ?? patient['endocrineDisorder'],
      alloantibodyPresent: patient['alloantibody_present'] ?? patient['alloantibodyPresent'],
      recurrentReactionFlag: patient['recurrent_reaction_flag'] ?? patient['recurrentReactionFlag'],
      profilePhotoUrl: patient['profile_photo_url'] ?? patient['profilePhotoUrl'] ?? patient['profileImageUrl'],
      userId: patient['user_id'] ?? patient['userId'],
    );
  }
}
