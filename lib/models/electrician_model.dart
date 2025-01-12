import 'package:flutter/material.dart';
import 'profile_model.dart';

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

  Electrician({
    required this.id,
    required this.profile,
    this.profileImage,
    required this.phone,
    required this.licenseNumber,
    required this.yearsOfExperience,
    required this.hourlyRate,
    this.rating = 0.0,
    this.jobsCompleted = 0,
    this.isAvailable = true,
    this.isVerified = false,
    List<Service>? services,
    List<String>? specialties,
    WorkingHours? workingHours,
    this.paymentInfo,
    NotificationPreferences? notificationPreferences,
  })  : services = services ?? [],
        specialties = specialties ?? [],
        workingHours = workingHours ?? WorkingHours(),
        notificationPreferences =
            notificationPreferences ?? NotificationPreferences();

  factory Electrician.fromMap(Map<String, dynamic> map,
      {required Profile profile}) {
    return Electrician(
      id: map['id'] as String,
      profile: profile,
      profileImage: map['profile_image'] as String?,
      phone: map['phone'] as String? ?? '',
      licenseNumber: map['license_number'] as String? ?? '',
      yearsOfExperience: map['years_of_experience'] as int? ?? 0,
      hourlyRate: (map['hourly_rate'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      jobsCompleted: map['jobs_completed'] as int? ?? 0,
      isAvailable: map['is_available'] as bool? ?? true,
      isVerified: map['is_verified'] as bool? ?? false,
      services: (map['services'] as List<dynamic>?)
              ?.map((e) => Service.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      specialties: (map['specialties'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      workingHours: map['working_hours'] != null
          ? WorkingHours.fromMap(map['working_hours'] as Map<String, dynamic>)
          : null,
      paymentInfo: map['payment_info'] != null
          ? PaymentInfo.fromMap(map['payment_info'] as Map<String, dynamic>)
          : null,
      notificationPreferences: map['notification_preferences'] != null
          ? NotificationPreferences.fromMap(
              map['notification_preferences'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
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
      'services': services.map((e) => e.toMap()).toList(),
      'specialties': specialties,
      'working_hours': workingHours.toMap(),
      'payment_info': paymentInfo?.toMap(),
      'notification_preferences': notificationPreferences.toMap(),
    };
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
    List<Service> services = const [],
    List<String> specialties = const [],
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
      services: services,
      specialties: specialties,
      workingHours: workingHours ?? this.workingHours,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
    );
  }
}

class Service {
  final String title;
  final double price;
  final String description;

  Service({
    required this.title,
    required this.price,
    required this.description,
  });

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      title: map['title'] as String,
      price: (map['price'] as num).toDouble(),
      description: map['description'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'description': description,
    };
  }
}

class WorkingHours {
  final Map<String, DaySchedule> schedule;

  WorkingHours({Map<String, DaySchedule>? schedule})
      : schedule = schedule ??
            {
              'Monday': DaySchedule(),
              'Tuesday': DaySchedule(),
              'Wednesday': DaySchedule(),
              'Thursday': DaySchedule(),
              'Friday': DaySchedule(),
              'Saturday': DaySchedule(),
              'Sunday': DaySchedule(),
            };

  factory WorkingHours.fromMap(Map<String, dynamic> map) {
    final schedule = <String, DaySchedule>{};
    map.forEach((key, value) {
      schedule[key] = DaySchedule.fromMap(value as Map<String, dynamic>);
    });
    return WorkingHours(schedule: schedule);
  }

  Map<String, dynamic> toMap() {
    return schedule.map((key, value) => MapEntry(key, value.toMap()));
  }
}

class DaySchedule {
  final bool isWorking;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  DaySchedule({
    this.isWorking = true,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  })  : startTime = startTime ?? const TimeOfDay(hour: 9, minute: 0),
        endTime = endTime ?? const TimeOfDay(hour: 17, minute: 0);

  factory DaySchedule.fromMap(Map<String, dynamic> map) {
    return DaySchedule(
      isWorking: map['is_working'] as bool? ?? true,
      startTime: TimeOfDay(
        hour: map['start_hour'] as int? ?? 9,
        minute: map['start_minute'] as int? ?? 0,
      ),
      endTime: TimeOfDay(
        hour: map['end_hour'] as int? ?? 17,
        minute: map['end_minute'] as int? ?? 0,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'is_working': isWorking,
      'start_hour': startTime.hour,
      'start_minute': startTime.minute,
      'end_hour': endTime.hour,
      'end_minute': endTime.minute,
    };
  }
}

class PaymentInfo {
  final String accountName;
  final String accountNumber;
  final String routingNumber;
  final String bankName;
  final String accountType;

  PaymentInfo({
    required this.accountName,
    required this.accountNumber,
    required this.routingNumber,
    required this.bankName,
    required this.accountType,
  });

  factory PaymentInfo.fromMap(Map<String, dynamic> map) {
    return PaymentInfo(
      accountName: map['account_name'] as String,
      accountNumber: map['account_number'] as String,
      routingNumber: map['routing_number'] as String,
      bankName: map['bank_name'] as String,
      accountType: map['account_type'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'account_name': accountName,
      'account_number': accountNumber,
      'routing_number': routingNumber,
      'bank_name': bankName,
      'account_type': accountType,
    };
  }
}

class NotificationPreferences {
  final bool newJobRequests;
  final bool jobUpdates;
  final bool messages;
  final bool weeklySummary;
  final bool paymentUpdates;
  final bool promotions;
  final bool quietHoursEnabled;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;

  NotificationPreferences({
    this.newJobRequests = true,
    this.jobUpdates = true,
    this.messages = true,
    this.weeklySummary = true,
    this.paymentUpdates = true,
    this.promotions = false,
    this.quietHoursEnabled = false,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
  })  : quietHoursStart =
            quietHoursStart ?? const TimeOfDay(hour: 22, minute: 0),
        quietHoursEnd = quietHoursEnd ?? const TimeOfDay(hour: 7, minute: 0);

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      newJobRequests: map['new_job_requests'] as bool? ?? true,
      jobUpdates: map['job_updates'] as bool? ?? true,
      messages: map['messages'] as bool? ?? true,
      weeklySummary: map['weekly_summary'] as bool? ?? true,
      paymentUpdates: map['payment_updates'] as bool? ?? true,
      promotions: map['promotions'] as bool? ?? false,
      quietHoursEnabled: map['quiet_hours_enabled'] as bool? ?? false,
      quietHoursStart: TimeOfDay(
        hour: map['quiet_hours_start_hour'] as int? ?? 22,
        minute: map['quiet_hours_start_minute'] as int? ?? 0,
      ),
      quietHoursEnd: TimeOfDay(
        hour: map['quiet_hours_end_hour'] as int? ?? 7,
        minute: map['quiet_hours_end_minute'] as int? ?? 0,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'new_job_requests': newJobRequests,
      'job_updates': jobUpdates,
      'messages': messages,
      'weekly_summary': weeklySummary,
      'payment_updates': paymentUpdates,
      'promotions': promotions,
      'quiet_hours_enabled': quietHoursEnabled,
      'quiet_hours_start_hour': quietHoursStart.hour,
      'quiet_hours_start_minute': quietHoursStart.minute,
      'quiet_hours_end_hour': quietHoursEnd.hour,
      'quiet_hours_end_minute': quietHoursEnd.minute,
    };
  }
}
