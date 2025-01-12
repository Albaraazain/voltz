import 'package:flutter/material.dart';
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
      'profile': profile.toJson(),
      'profileImage': profileImage,
      'phone': phone,
      'licenseNumber': licenseNumber,
      'yearsOfExperience': yearsOfExperience,
      'hourlyRate': hourlyRate,
      'rating': rating,
      'jobsCompleted': jobsCompleted,
      'isAvailable': isAvailable,
      'isVerified': isVerified,
      'services': services.map((s) => s.toJson()).toList(),
      'specialties': specialties,
      'workingHours': workingHours.toJson(),
      'paymentInfo': paymentInfo?.toJson(),
      'notificationPreferences': notificationPreferences.toJson(),
    };
  }

  factory Electrician.fromJson(Map<String, dynamic> json) {
    return Electrician(
      id: json['id'] ?? '',
      profile: Profile.fromJson(json['profile']),
      profileImage: json['profile_image'],
      phone: json['phone'] ?? '',
      licenseNumber: json['license_number'] ?? '',
      yearsOfExperience: json['years_of_experience'] ?? 0,
      hourlyRate: (json['hourly_rate'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      jobsCompleted: json['jobs_completed'] ?? 0,
      isAvailable: json['is_available'] ?? false,
      isVerified: json['is_verified'] ?? false,
      services: json['services'] != null
          ? (json['services'] as List).map((s) => Service.fromJson(s)).toList()
          : [],
      specialties: json['specialties'] != null
          ? List<String>.from(json['specialties'])
          : [],
      workingHours: json['working_hours'] != null
          ? WorkingHours.fromJson(json['working_hours'])
          : const WorkingHours(),
      paymentInfo: json['payment_info'] != null
          ? PaymentInfo.fromJson(json['payment_info'])
          : null,
      notificationPreferences: json['notification_preferences'] != null
          ? NotificationPreferences.fromJson(json['notification_preferences'])
          : const NotificationPreferences(),
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
}
