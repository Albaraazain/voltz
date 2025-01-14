import '../models/job_model.dart';

class ScheduleSlot {
  static const String STATUS_AVAILABLE = 'AVAILABLE';
  static const String STATUS_BOOKED = 'BOOKED';
  static const String STATUS_BLOCKED = 'BLOCKED';

  final String id;
  final String electricianId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status;
  final String? jobId;
  final Job? job;
  final String? recurringRule;
  final DateTime createdAt;
  final DateTime updatedAt;

  ScheduleSlot({
    required this.id,
    required this.electricianId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.jobId,
    this.job,
    this.recurringRule,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScheduleSlot.fromJson(Map<String, dynamic> json) {
    return ScheduleSlot(
      id: json['id'],
      electricianId: json['electrician_id'],
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'],
      jobId: json['job_id'],
      job: json['job'] != null ? Job.fromJson(json['job']) : null,
      recurringRule: json['recurring_rule'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'electrician_id': electricianId,
      'date': date.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'job_id': jobId,
      'job': job?.toJson(),
      'recurring_rule': recurringRule,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ScheduleSlot copyWith({
    String? id,
    String? electricianId,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? status,
    String? jobId,
    Job? job,
    String? recurringRule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleSlot(
      id: id ?? this.id,
      electricianId: electricianId ?? this.electricianId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      jobId: jobId ?? this.jobId,
      job: job ?? this.job,
      recurringRule: recurringRule ?? this.recurringRule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WorkingHours {
  final String id;
  final String electricianId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isWorkingDay;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkingHours({
    required this.id,
    required this.electricianId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isWorkingDay,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      id: json['id'],
      electricianId: json['electrician_id'],
      dayOfWeek: json['day_of_week'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isWorkingDay: json['is_working_day'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'electrician_id': electricianId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_working_day': isWorkingDay,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WorkingHours copyWith({
    String? id,
    String? electricianId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isWorkingDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkingHours(
      id: id ?? this.id,
      electricianId: electricianId ?? this.electricianId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isWorkingDay: isWorkingDay ?? this.isWorkingDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  String get dayName {
    switch (dayOfWeek) {
      case 0:
        return 'Sunday';
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      default:
        return '';
    }
  }
}
