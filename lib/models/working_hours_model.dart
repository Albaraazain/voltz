import 'package:flutter/material.dart';

class WorkingHours {
  final List<bool> workingDays;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool hasBreak;
  final TimeOfDay breakStartTime;
  final TimeOfDay breakEndTime;

  const WorkingHours({
    this.workingDays = const [true, true, true, true, true, false, false],
    this.startTime = const TimeOfDay(hour: 9, minute: 0),
    this.endTime = const TimeOfDay(hour: 17, minute: 0),
    this.hasBreak = true,
    this.breakStartTime = const TimeOfDay(hour: 12, minute: 0),
    this.breakEndTime = const TimeOfDay(hour: 13, minute: 0),
  });

  WorkingHours copyWith({
    List<bool>? workingDays,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? hasBreak,
    TimeOfDay? breakStartTime,
    TimeOfDay? breakEndTime,
  }) {
    return WorkingHours(
      workingDays: workingDays ?? this.workingDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      hasBreak: hasBreak ?? this.hasBreak,
      breakStartTime: breakStartTime ?? this.breakStartTime,
      breakEndTime: breakEndTime ?? this.breakEndTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workingDays': workingDays,
      'startTime': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'endTime': {
        'hour': endTime.hour,
        'minute': endTime.minute,
      },
      'hasBreak': hasBreak,
      'breakStartTime': {
        'hour': breakStartTime.hour,
        'minute': breakStartTime.minute,
      },
      'breakEndTime': {
        'hour': breakEndTime.hour,
        'minute': breakEndTime.minute,
      },
    };
  }

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      workingDays: List<bool>.from(json['workingDays']),
      startTime: TimeOfDay(
        hour: json['startTime']['hour'],
        minute: json['startTime']['minute'],
      ),
      endTime: TimeOfDay(
        hour: json['endTime']['hour'],
        minute: json['endTime']['minute'],
      ),
      hasBreak: json['hasBreak'],
      breakStartTime: TimeOfDay(
        hour: json['breakStartTime']['hour'],
        minute: json['breakStartTime']['minute'],
      ),
      breakEndTime: TimeOfDay(
        hour: json['breakEndTime']['hour'],
        minute: json['breakEndTime']['minute'],
      ),
    );
  }
}
