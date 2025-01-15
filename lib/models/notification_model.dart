/// Represents a notification in the system.
///
/// The notification system has been updated to use a unified schema that works for both
/// homeowners and electricians. Each notification is associated with a user's profile_id
/// rather than being specific to electricians or homeowners.
///
/// Database schema:
/// - id: UUID (Primary Key)
/// - profile_id: UUID (Foreign Key to profiles table)
/// - title: TEXT (Notification title)
/// - message: TEXT (Notification content)
/// - type: TEXT (One of: 'job_request', 'job_update', 'payment', 'review', 'system')
/// - read: BOOLEAN (Whether the notification has been read)
/// - related_id: UUID (Optional reference to related entity like job, review, etc.)
/// - created_at: TIMESTAMP WITH TIME ZONE
/// - updated_at: TIMESTAMP WITH TIME ZONE

/// Types of notifications supported by the system.
/// These types match the database schema's CHECK constraint.
///
/// Note: When adding new types, make sure to update the database schema's CHECK constraint
/// in the notifications table.
enum NotificationType {
  jobRequest, // New job request received
  jobUpdate, // General job status update
  jobAccepted, // Job was accepted by electrician
  jobDeclined, // Job was declined by electrician
  jobRejected, // Job was rejected by homeowner
  jobCompleted, // Job was marked as completed
  payment, // Payment-related notification
  review, // Review-related notification
  message, // Chat or direct message notification
  system, // System-level notification
}

class NotificationModel {
  final String id;
  final String profileId;
  final String title;
  final String message;
  final NotificationType type;
  final bool read;
  final String? relatedId; // ID of the related entity (job, review, etc.)
  final DateTime createdAt;
  final DateTime updatedAt;

  static const String TYPE_JOB_REQUEST = 'job_request';
  static const String TYPE_JOB_UPDATE = 'job_update';
  static const String TYPE_PAYMENT = 'payment';
  static const String TYPE_REVIEW = 'review';
  static const String TYPE_SYSTEM = 'system';

  const NotificationModel({
    required this.id,
    required this.profileId,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    this.relatedId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: _typeFromString(json['type'] as String),
      read: json['read'] as bool,
      relatedId: json['related_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel.fromJson(map);
  }

  static NotificationType _typeFromString(String type) {
    switch (type) {
      case 'job_request':
        return NotificationType.jobRequest;
      case 'job_update':
        return NotificationType.jobUpdate;
      case 'job_accepted':
        return NotificationType.jobAccepted;
      case 'job_declined':
        return NotificationType.jobDeclined;
      case 'job_rejected':
        return NotificationType.jobRejected;
      case 'job_completed':
        return NotificationType.jobCompleted;
      case 'payment':
        return NotificationType.payment;
      case 'review':
        return NotificationType.review;
      case 'message':
        return NotificationType.message;
      case 'system':
        return NotificationType.system;
      default:
        throw ArgumentError('Unknown notification type: $type');
    }
  }

  static String _typeToString(NotificationType type) {
    switch (type) {
      case NotificationType.jobRequest:
        return 'job_request';
      case NotificationType.jobUpdate:
        return 'job_update';
      case NotificationType.jobAccepted:
        return 'job_accepted';
      case NotificationType.jobDeclined:
        return 'job_declined';
      case NotificationType.jobRejected:
        return 'job_rejected';
      case NotificationType.jobCompleted:
        return 'job_completed';
      case NotificationType.payment:
        return 'payment';
      case NotificationType.review:
        return 'review';
      case NotificationType.message:
        return 'message';
      case NotificationType.system:
        return 'system';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'title': title,
      'message': message,
      'type': _typeToString(type),
      'read': read,
      'related_id': relatedId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  NotificationModel copyWith({
    String? id,
    String? profileId,
    String? title,
    String? message,
    NotificationType? type,
    bool? read,
    String? relatedId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      read: read ?? this.read,
      relatedId: relatedId ?? this.relatedId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationModel &&
        other.id == id &&
        other.profileId == profileId &&
        other.title == title &&
        other.message == message &&
        other.type == type &&
        other.read == read &&
        other.relatedId == relatedId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        profileId.hashCode ^
        title.hashCode ^
        message.hashCode ^
        type.hashCode ^
        read.hashCode ^
        relatedId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
