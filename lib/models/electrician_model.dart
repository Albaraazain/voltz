import 'profile_model.dart';

class Electrician {
  final String id;
  final Profile profile;
  final double rating;
  final int jobsCompleted;
  final double hourlyRate;
  final String? profileImage;
  final bool isAvailable;
  final List<String> specialties;
  final String? licenseNumber;
  final int yearsOfExperience;
  final DateTime createdAt;

  Electrician({
    required this.id,
    required this.profile,
    this.rating = 0.0,
    this.jobsCompleted = 0,
    this.hourlyRate = 0.0,
    this.profileImage,
    this.isAvailable = true,
    this.specialties = const [],
    this.licenseNumber,
    this.yearsOfExperience = 0,
    required this.createdAt,
  });

  factory Electrician.fromMap(Map<String, dynamic> map, {Profile? profile}) {
    return Electrician(
      id: map['id'],
      profile: profile ?? Profile.fromMap(map['profile']),
      rating: map['rating']?.toDouble() ?? 0.0,
      jobsCompleted: map['jobs_completed'] ?? 0,
      hourlyRate: map['hourly_rate']?.toDouble() ?? 0.0,
      profileImage: map['profile_image'],
      isAvailable: map['is_available'] ?? true,
      specialties: List<String>.from(map['specialties'] ?? []),
      licenseNumber: map['license_number'],
      yearsOfExperience: map['years_of_experience'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profile.id,
      'rating': rating,
      'jobs_completed': jobsCompleted,
      'hourly_rate': hourlyRate,
      'profile_image': profileImage,
      'is_available': isAvailable,
      'specialties': specialties,
      'license_number': licenseNumber,
      'years_of_experience': yearsOfExperience,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Electrician copyWith({
    String? id,
    Profile? profile,
    double? rating,
    int? jobsCompleted,
    double? hourlyRate,
    String? profileImage,
    bool? isAvailable,
    List<String>? specialties,
    String? licenseNumber,
    int? yearsOfExperience,
    DateTime? createdAt,
  }) {
    return Electrician(
      id: id ?? this.id,
      profile: profile ?? this.profile,
      rating: rating ?? this.rating,
      jobsCompleted: jobsCompleted ?? this.jobsCompleted,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      profileImage: profileImage ?? this.profileImage,
      isAvailable: isAvailable ?? this.isAvailable,
      specialties: specialties ?? this.specialties,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // TODO: Implement electrician verification and background check system
  // TODO: Add certification and license management
  // TODO: Implement skill assessment and rating system
  // TODO: Add availability calendar with time slots
  // TODO: Implement service area management
  // TODO: Add team/crew management for larger operations
  // TODO: Implement equipment and inventory tracking
  // TODO: Add specialization and expertise categorization
  // TODO: Implement work history and portfolio
  // TODO: Add insurance verification system
}
