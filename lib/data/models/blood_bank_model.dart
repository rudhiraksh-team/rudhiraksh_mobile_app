class BloodBank {
  final int id;
  final String name;
  final String logoUrl;
  final String? contactEmail;
  final String address;
  final String? contactPhone;
  final String? description;
  final String? termsAndConditions;

  BloodBank({
    required this.id,
    required this.name,
    required this.logoUrl,
    this.contactEmail,
    required this.address,
    this.contactPhone,
    this.description,
    this.termsAndConditions,
  });

  factory BloodBank.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return BloodBank(
      id: data['id'],
      name: data['name'],
      logoUrl: data['logo_url'] ?? data['logoUrl'] ?? '',
      contactEmail: data['contact_email'] ?? data['contactEmail'],
      address: data['metadata']?['address'] ?? data['address'] ?? '',
      contactPhone: data['contact_phone'] ?? data['contactPhone'],
      description: data['description'],
      termsAndConditions: data['terms_and_conditions'] ?? data['termsAndConditions'],
    );
  }
}
