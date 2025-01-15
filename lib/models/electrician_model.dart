import 'profile_model.dart';
import 'service_model.dart';
import 'working_hours_model.dart';
import 'payment_info_model.dart';
import 'notification_preferences_model.dart';

class Electrician {
  final String id;
  final Profile profile;
  final String? profileImage;
  final String phone;
  final String licenseNumber;
  final int yearsOfExperience;
  final double hourlyRate;
  final double rating;
  final int jobsCompleted;
  final bool isAvailable;
  final bool isVerified;
  final List<Service> services;
  final List<String> specialties;
  final WorkingHours workingHours;
  final PaymentInfo? paymentInfo;
  final NotificationPreferences notificationPreferences;

  const Electrician({
    required this.id,
    required this.profile,
    this.profileImage,
    required this.phone,
    required this.licenseNumber,
    required this.yearsOfExperience,
    required this.hourlyRate,
    required this.rating,
    required this.jobsCompleted,
    required this.isAvailable,
    required this.isVerified,
    this.services = const [],
    this.specialties = const [],
    required this.workingHours,
    this.paymentInfo,
    required this.notificationPreferences,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profile.id,
      'profile_image': profileImage,
      'phone': phone,
      'license_number': licenseNumber,
      'years_of_experience': yearsOfExperience,
      'hourly_rate': hourlyRate,
      'rating': rating,
      'jobs_completed': jobsCompleted,
      'is_available': isAvailable,
      'is_verified': isVerified,
      'services': services.map((s) => s.toJson()).toList(),
      'specialties': specialties,
      'working_hours': workingHours.toJson(),
      'payment_info': paymentInfo?.toJson(),
      'notification_preferences': notificationPreferences.toJson(),
    };
  }

  factory Electrician.fromJson(Map<String, dynamic> json) {
    return Electrician(
      id: json['id'],
      profile: Profile.fromJson(json['profile']),
      profileImage: json['profile_image'],
      phone: json['phone'] ?? '',
      licenseNumber: json['license_number'] ?? '',
      yearsOfExperience: json['years_of_experience'] ?? 0,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      jobsCompleted: json['jobs_completed'] ?? 0,
      isAvailable: json['is_available'] ?? true,
      isVerified: json['is_verified'] ?? false,
      services: (json['services'] as List?)
              ?.map((s) => Service.fromJson(s))
              .toList() ??
          [],
      specialties: List<String>.from(json['specialties'] ?? []),
      workingHours: WorkingHours.fromJson(json['working_hours']),
      paymentInfo: json['payment_info'] != null
          ? PaymentInfo.fromJson(json['payment_info'])
          : null,
      notificationPreferences: json['notification_preferences'] != null
          ? NotificationPreferences.fromJson(json['notification_preferences'])
          : NotificationPreferences.defaults(),
    );
  }

  Electrician copyWith({
    String? id,
    Profile? profile,
    String? profileImage,
    String? phone,
    String? licenseNumber,
    int? yearsOfExperience,
    double? hourlyRate,
    double? rating,
    int? jobsCompleted,
    bool? isAvailable,
    bool? isVerified,
    List<Service>? services,
    List<String>? specialties,
    WorkingHours? workingHours,
    PaymentInfo? paymentInfo,
    NotificationPreferences? notificationPreferences,
  }) {
    return Electrician(
      id: id ?? this.id,
      profile: profile ?? this.profile,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      rating: rating ?? this.rating,
      jobsCompleted: jobsCompleted ?? this.jobsCompleted,
      isAvailable: isAvailable ?? this.isAvailable,
      isVerified: isVerified ?? this.isVerified,
      services: services ?? this.services,
      specialties: specialties ?? this.specialties,
      workingHours: workingHours ?? this.workingHours,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
    );
  }

  // Helper methods for working hours
  bool isDayEnabled(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return workingHours.monday != null;
      case 'tuesday':
        return workingHours.tuesday != null;
      case 'wednesday':
        return workingHours.wednesday != null;
      case 'thursday':
        return workingHours.thursday != null;
      case 'friday':
        return workingHours.friday != null;
      case 'saturday':
        return workingHours.saturday != null;
      case 'sunday':
        return workingHours.sunday != null;
      default:
        return false;
    }
  }

  String? getDayStartTime(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return workingHours.monday?.start;
      case 'tuesday':
        return workingHours.tuesday?.start;
      case 'wednesday':
        return workingHours.wednesday?.start;
      case 'thursday':
        return workingHours.thursday?.start;
      case 'friday':
        return workingHours.friday?.start;
      case 'saturday':
        return workingHours.saturday?.start;
      case 'sunday':
        return workingHours.sunday?.start;
      default:
        return null;
    }
  }

  String? getDayEndTime(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return workingHours.monday?.end;
      case 'tuesday':
        return workingHours.tuesday?.end;
      case 'wednesday':
        return workingHours.wednesday?.end;
      case 'thursday':
        return workingHours.thursday?.end;
      case 'friday':
        return workingHours.friday?.end;
      case 'saturday':
        return workingHours.saturday?.end;
      case 'sunday':
        return workingHours.sunday?.end;
      default:
        return null;
    }
  }
}
