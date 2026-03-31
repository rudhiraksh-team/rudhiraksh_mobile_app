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
    if (data == null || data['patient'] == null) {
      throw Exception("Patient data is missing");
    }

    final patient = data['patient'];

    // Build full name from parts if available
    final firstName = patient['first_name'] ?? patient['firstName'] ?? '';
    final middleName = patient['middle_name'] ?? patient['middleName'];
    final surname = patient['surname'] ?? patient['last_name'] ?? patient['lastName'] ?? '';
    final fullName = patient['full_name'] ?? patient['fullName'] ??
        [firstName, middleName, surname].where((s) => s != null && s.toString().isNotEmpty).join(' ');

    return Patient(
      id: patient['id'] ?? 0,
      bloodbankId: patient['bloodbank_id'] ?? patient['bloodBankId'] ?? 0,
      firstName: firstName,
      middleName: middleName,
      surname: surname,
      fullName: fullName,
      dateOfBirth: patient['date_of_birth'] ?? patient['dateOfBirth'] ?? '',
      gender: patient['gender'] ?? '',
      phoneNumber: patient['phone_number'] ?? patient['phoneNumber'] ?? '',
      email: patient['email'] ?? '',
      addressStreet: patient['address_street'] ?? patient['street'] ?? '',
      addressArea: patient['address_area'] ?? patient['area'] ?? '',
      addressCity: patient['address_city'] ?? patient['city'] ?? '',
      addressState: patient['address_state'] ?? patient['state'] ?? '',
      addressPincode: patient['address_pincode'] ?? patient['pinCode'] ?? '',
      bloodGroup: patient['blood_group'] ?? patient['bloodGroup'] ?? '',
      thalassemiaType: patient['thalassemia_type'] ?? patient['thalassemiaType'] ?? '',
      emergencyContactName: patient['emergency_contact_name'] ?? patient['emergencyContactName'] ?? '',
      emergencyContactPhone: patient['emergency_contact_phone'] ?? patient['emergencyContactPhone'] ?? '',
      emergencyContactPhone2: patient['emergency_contact_phone_2'] ?? patient['emergencyContactPhone2'],
      abhaId: patient['abha_id'] ?? patient['abhaId'],
      thalassemiaPatientId: patient['thalassemia_patient_id'] ?? patient['thalassemiaPatientId'],
      patientStatus: patient['status'] ?? patient['patientStatus'] ?? 'active',
      diagnosisDate: patient['diagnosis_date'] ?? patient['diagnosisDate'],
      ferritinLevel: patient['ferritin_level'] != null ? (patient['ferritin_level'] as num).toDouble() : null,
      assignedDoctorId: patient['assigned_doctor_id'] ?? patient['assignedDoctorId'],
      assignedDoctorName: patient['assigned_doctor_name'] ?? patient['assignedDoctorName'],
      cardiacComplication: patient['cardiac_complication'] ?? patient['cardiacComplication'],
      liverEnlargement: patient['liver_enlargement'] ?? patient['liverEnlargement'],
      endocrineDisorder: patient['endocrine_disorder'] ?? patient['endocrineDisorder'],
      alloantibodyPresent: patient['alloantibody_present'] ?? patient['alloantibodyPresent'],
      recurrentReactionFlag: patient['recurrent_reaction_flag'] ?? patient['recurrentReactionFlag'],
      profilePhotoUrl: patient['profile_photo_url'] ?? patient['profilePhotoUrl'],
      userId: patient['user_id'] ?? patient['userId'],
    );
  }
}
