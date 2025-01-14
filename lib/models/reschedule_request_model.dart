import 'package:flutter/material.dart';

class RescheduleRequest {
  final String id;
  final String jobId;
  final String requestedById;
  final String requestedByType;
  final String originalDate;
  final String originalTime;
  final String proposedDate;
  final String proposedTime;
  final String status;
  final String? reason;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Status constants
  static const String STATUS_PENDING = 'PENDING';
  static const String STATUS_ACCEPTED = 'ACCEPTED';
  static const String STATUS_DECLINED = 'DECLINED';

  const RescheduleRequest({
    required this.id,
    required this.jobId,
    required this.requestedById,
    required this.requestedByType,
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
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      requestedById: json['requested_by_id'] as String,
      requestedByType: json['requested_by_type'] as String,
      originalDate: json['original_date'] as String,
      originalTime: json['original_time'] as String,
      proposedDate: json['proposed_date'] as String,
      proposedTime: json['proposed_time'] as String,
      status: json['status'] as String,
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'requested_by_id': requestedById,
      'requested_by_type': requestedByType,
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
    String? requestedByType,
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
      requestedByType: requestedByType ?? this.requestedByType,
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
