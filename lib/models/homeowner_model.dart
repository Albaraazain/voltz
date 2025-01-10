import 'profile_model.dart';

class Homeowner {
  final String id;
  final Profile profile;
  final String? phone;
  final String? address;
  final String preferredContactMethod;
  final String? emergencyContact;
  final DateTime createdAt;

  Homeowner({
    required this.id,
    required this.profile,
    this.phone,
    this.address,
    this.preferredContactMethod = 'email',
    this.emergencyContact,
    required this.createdAt,
  });

  factory Homeowner.fromMap(Map<String, dynamic> map, {Profile? profile}) {
    return Homeowner(
      id: map['id'],
      profile: profile ?? Profile.fromMap(map['profile']),
      phone: map['phone'],
      address: map['address'],
      preferredContactMethod: map['preferred_contact_method'] ?? 'email',
      emergencyContact: map['emergency_contact'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
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

  Homeowner copyWith({
    String? id,
    Profile? profile,
    String? phone,
    String? address,
    String? preferredContactMethod,
    String? emergencyContact,
    DateTime? createdAt,
  }) {
    return Homeowner(
      id: id ?? this.id,
      profile: profile ?? this.profile,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      preferredContactMethod:
          preferredContactMethod ?? this.preferredContactMethod,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
