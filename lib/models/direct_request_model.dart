import 'package:flutter/material.dart';
import 'job_model.dart';

class DirectRequest {
  final String id;
  final String jobId;
  final String homeownerId;
  final String electricianId;
  final DateTime preferredDate;
  final TimeOfDay preferredTime;
  final String status; // PENDING, ACCEPTED, DECLINED
  final String? message;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Status constants
  static const String STATUS_PENDING = 'PENDING';
  static const String STATUS_ACCEPTED = 'ACCEPTED';
  static const String STATUS_DECLINED = 'DECLINED';

  const DirectRequest({
    required this.id,
    required this.jobId,
    required this.homeownerId,
    required this.electricianId,
    required this.preferredDate,
    required this.preferredTime,
    required this.status,
    this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create from JSON (Supabase response)
  factory DirectRequest.fromJson(Map<String, dynamic> json) {
    return DirectRequest(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      homeownerId: json['homeowner_id'] as String,
      electricianId: json['electrician_id'] as String,
      preferredDate: DateTime.parse(json['preferred_date'] as String),
      preferredTime: _timeFromString(json['preferred_time'] as String),
      status: json['status'] as String,
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'homeowner_id': homeownerId,
      'electrician_id': electricianId,
      'preferred_date': preferredDate.toIso8601String().split('T')[0],
      'preferred_time': _timeToString(preferredTime),
      'status': status,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper method to convert TimeOfDay to string
  static String _timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  // Helper method to convert string to TimeOfDay
  static TimeOfDay _timeFromString(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  // Create a copy with some fields updated
  DirectRequest copyWith({
    String? id,
    String? jobId,
    String? homeownerId,
    String? electricianId,
    DateTime? preferredDate,
    TimeOfDay? preferredTime,
    String? status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DirectRequest(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      homeownerId: homeownerId ?? this.homeownerId,
      electricianId: electricianId ?? this.electricianId,
      preferredDate: preferredDate ?? this.preferredDate,
      preferredTime: preferredTime ?? this.preferredTime,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get formatted preferred time
  String get formattedPreferredTime {
    final hour = preferredTime.hour == 0
        ? 12
        : (preferredTime.hour > 12
            ? preferredTime.hour - 12
            : preferredTime.hour);
    final minute = preferredTime.minute.toString().padLeft(2, '0');
    final period = preferredTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Get formatted preferred date
  String get formattedPreferredDate {
    return '${preferredDate.year}-${preferredDate.month.toString().padLeft(2, '0')}-${preferredDate.day.toString().padLeft(2, '0')}';
  }

  // Check if request is pending
  bool get isPending => status == STATUS_PENDING;

  // Check if request is accepted
  bool get isAccepted => status == STATUS_ACCEPTED;

  // Check if request is declined
  bool get isDeclined => status == STATUS_DECLINED;

  // Get status text for display
  String get statusText {
    switch (status) {
      case STATUS_PENDING:
        return 'Pending';
      case STATUS_ACCEPTED:
        return 'Accepted';
      case STATUS_DECLINED:
        return 'Declined';
      default:
        return status;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DirectRequest &&
        other.id == id &&
        other.jobId == jobId &&
        other.homeownerId == homeownerId &&
        other.electricianId == electricianId &&
        other.preferredDate == preferredDate &&
        other.preferredTime == preferredTime &&
        other.status == status &&
        other.message == message;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      jobId,
      homeownerId,
      electricianId,
      preferredDate,
      preferredTime,
      status,
      message,
    );
  }
}
