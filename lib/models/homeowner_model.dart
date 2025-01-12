import 'profile_model.dart';

class Homeowner {
  final String id;
  final Profile profile;
  final String? phone;
  final String? address;
  final String preferredContactMethod;
  final String? emergencyContact;
  final DateTime createdAt;

  const Homeowner({
    required this.id,
    required this.profile,
    this.phone,
    this.address,
    this.preferredContactMethod = 'email',
    this.emergencyContact,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profile.id,
      'phone': phone,
      'address': address,
      'preferred_contact_method': preferredContactMethod,
      'emergency_contact': emergencyContact,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Homeowner.fromJson(Map<String, dynamic> json, {Profile? profile}) {
    return Homeowner(
      id: json['id'],
      profile: profile ?? Profile.fromJson(json['profile']),
      phone: json['phone'],
      address: json['address'],
      preferredContactMethod: json['preferred_contact_method'] ?? 'email',
      emergencyContact: json['emergency_contact'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
