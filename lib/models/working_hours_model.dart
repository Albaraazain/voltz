import 'package:flutter/material.dart';

class WorkingHours {
  final Map<String, DaySchedule?> schedule;

  const WorkingHours({
    this.schedule = const {
      'monday': DaySchedule(start: '09:00', end: '17:00'),
      'tuesday': DaySchedule(start: '09:00', end: '17:00'),
      'wednesday': DaySchedule(start: '09:00', end: '17:00'),
      'thursday': DaySchedule(start: '09:00', end: '17:00'),
      'friday': DaySchedule(start: '09:00', end: '17:00'),
      'saturday': null,
      'sunday': null,
    },
  });

  WorkingHours copyWith({
    Map<String, DaySchedule?>? schedule,
  }) {
    return WorkingHours(
      schedule: schedule ?? this.schedule,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monday': schedule['monday']?.toJson(),
      'tuesday': schedule['tuesday']?.toJson(),
      'wednesday': schedule['wednesday']?.toJson(),
      'thursday': schedule['thursday']?.toJson(),
      'friday': schedule['friday']?.toJson(),
      'saturday': schedule['saturday']?.toJson(),
      'sunday': schedule['sunday']?.toJson(),
    };
  }

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      schedule: {
        'monday': json['monday'] != null
            ? DaySchedule.fromJson(json['monday'])
            : null,
        'tuesday': json['tuesday'] != null
            ? DaySchedule.fromJson(json['tuesday'])
            : null,
        'wednesday': json['wednesday'] != null
            ? DaySchedule.fromJson(json['wednesday'])
            : null,
        'thursday': json['thursday'] != null
            ? DaySchedule.fromJson(json['thursday'])
            : null,
        'friday': json['friday'] != null
            ? DaySchedule.fromJson(json['friday'])
            : null,
        'saturday': json['saturday'] != null
            ? DaySchedule.fromJson(json['saturday'])
            : null,
        'sunday': json['sunday'] != null
            ? DaySchedule.fromJson(json['sunday'])
            : null,
      },
    );
  }
}

class DaySchedule {
  final String start;
  final String end;

  const DaySchedule({
    required this.start,
    required this.end,
  });

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
    };
  }

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      start: json['start'],
      end: json['end'],
    );
  }
}
