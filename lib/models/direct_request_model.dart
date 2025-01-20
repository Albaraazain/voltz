import 'package:intl/intl.dart';

class DirectRequest {
  static const String STATUS_PENDING = 'PENDING';
  static const String STATUS_ACCEPTED = 'ACCEPTED';
  static const String STATUS_DECLINED = 'DECLINED';
  static const String STATUS_CANCELLED = 'CANCELLED';
  static const String STATUS_RESCHEDULED = 'RESCHEDULED';
  static const String STATUS_IN_PROGRESS = 'IN_PROGRESS';
  static const String STATUS_COMPLETED = 'COMPLETED';

  final String id;
  final String homeownerId;
  final String electricianId;
  final String description;
  final String preferredDate;
  final String preferredTime;
  final String status;
  final String? declineReason;
  final String? cancellationReason;
  final String? alternativeDate;
  final String? alternativeTime;
  final String? alternativeMessage;
  final DateTime? startTime;
  final DateTime? completionTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  DirectRequest({
    required this.id,
    required this.homeownerId,
    required this.electricianId,
    required this.description,
    required this.preferredDate,
    required this.preferredTime,
    required this.status,
    this.declineReason,
    this.cancellationReason,
    this.alternativeDate,
    this.alternativeTime,
    this.alternativeMessage,
    this.startTime,
    this.completionTime,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusText {
    switch (status) {
      case STATUS_PENDING:
        return 'Pending';
      case STATUS_ACCEPTED:
        return 'Accepted';
      case STATUS_DECLINED:
        return 'Declined';
      case STATUS_CANCELLED:
        return 'Cancelled';
      case STATUS_RESCHEDULED:
        return 'Rescheduled';
      case STATUS_IN_PROGRESS:
        return 'In Progress';
      case STATUS_COMPLETED:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  String get formattedPreferredDate {
    final date = DateTime.parse(preferredDate);
    return DateFormat('MMM d, yyyy').format(date);
  }

  String get formattedPreferredTime {
    return preferredTime;
  }

  String? get message => alternativeMessage;

  factory DirectRequest.fromJson(Map<String, dynamic> json) {
    return DirectRequest(
      id: json['id'],
      homeownerId: json['homeowner_id'],
      electricianId: json['electrician_id'],
      description: json['description'],
      preferredDate: json['preferred_date'],
      preferredTime: json['preferred_time'],
      status: json['status'],
      declineReason: json['decline_reason'],
      cancellationReason: json['cancellation_reason'],
      alternativeDate: json['alternative_date'],
      alternativeTime: json['alternative_time'],
      alternativeMessage: json['alternative_message'],
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null,
      completionTime: json['completion_time'] != null
          ? DateTime.parse(json['completion_time'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homeowner_id': homeownerId,
      'electrician_id': electricianId,
      'description': description,
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'status': status,
      'decline_reason': declineReason,
      'cancellation_reason': cancellationReason,
      'alternative_date': alternativeDate,
      'alternative_time': alternativeTime,
      'alternative_message': alternativeMessage,
      'start_time': startTime?.toIso8601String(),
      'completion_time': completionTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
