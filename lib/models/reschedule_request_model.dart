import 'package:flutter/material.dart';

class RescheduleRequest {
  static const String STATUS_PENDING = 'PENDING';
  static const String STATUS_ACCEPTED = 'ACCEPTED';
  static const String STATUS_DECLINED = 'DECLINED';

  final String id;
  final String jobId;
  final String requestedById;
  final String originalDate;
  final String originalTime;
  final String proposedDate;
  final String proposedTime;
  final String status;
  final String? reason;
  final DateTime createdAt;
  final DateTime updatedAt;

  RescheduleRequest({
    required this.id,
    required this.jobId,
    required this.requestedById,
    required this.originalDate,
    required this.originalTime,
    required this.proposedDate,
    required this.proposedTime,
    required this.status,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RescheduleRequest.fromJson(Map<String, dynamic> json) {
    return RescheduleRequest(
      id: json['id'],
      jobId: json['job_id'],
      requestedById: json['requested_by_id'],
      originalDate: json['original_date'],
      originalTime: json['original_time'],
      proposedDate: json['proposed_date'],
      proposedTime: json['proposed_time'],
      status: json['status'],
      reason: json['reason'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'requested_by_id': requestedById,
      'original_date': originalDate,
      'original_time': originalTime,
      'proposed_date': proposedDate,
      'proposed_time': proposedTime,
      'status': status,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  RescheduleRequest copyWith({
    String? id,
    String? jobId,
    String? requestedById,
    String? originalDate,
    String? originalTime,
    String? proposedDate,
    String? proposedTime,
    String? status,
    String? reason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RescheduleRequest(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      requestedById: requestedById ?? this.requestedById,
      originalDate: originalDate ?? this.originalDate,
      originalTime: originalTime ?? this.originalTime,
      proposedDate: proposedDate ?? this.proposedDate,
      proposedTime: proposedTime ?? this.proposedTime,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
