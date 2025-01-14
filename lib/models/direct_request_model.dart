import 'package:flutter/material.dart';
import 'job_model.dart';
import 'package:intl/intl.dart';

class DirectRequest {
  static const String STATUS_PENDING = 'PENDING';
  static const String STATUS_ACCEPTED = 'ACCEPTED';
  static const String STATUS_DECLINED = 'DECLINED';

  final String id;
  final String homeownerId;
  final String electricianId;
  final String description;
  final String preferredDate;
  final String preferredTime;
  final String status;
  final String? declineReason;
  final String? alternativeDate;
  final String? alternativeTime;
  final String? alternativeMessage;
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
    this.alternativeDate,
    this.alternativeTime,
    this.alternativeMessage,
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
      alternativeDate: json['alternative_date'],
      alternativeTime: json['alternative_time'],
      alternativeMessage: json['alternative_message'],
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
      'alternative_date': alternativeDate,
      'alternative_time': alternativeTime,
      'alternative_message': alternativeMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
