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
      'profile': profile.toJson(),
      'phone': phone,
      'address': address,
      'preferredContactMethod': preferredContactMethod,
      'emergencyContact': emergencyContact,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Homeowner.fromJson(Map<String, dynamic> json) {
    return Homeowner(
      id: json['id'],
      profile: Profile.fromJson(json['profile']),
      phone: json['phone'],
      address: json['address'],
      preferredContactMethod: json['preferredContactMethod'],
      emergencyContact: json['emergencyContact'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
