enum NotificationType {
  jobRequest,
  jobAccepted,
  jobDeclined,
  jobRejected,
  jobCompleted,
  payment,
  review,
  message,
  system,
}

class NotificationModel {
  final String id;
  final String electricianId;
  final String title;
  final String message;
  final NotificationType type;
  final bool read;
  final DateTime createdAt;
  final DateTime updatedAt;

  static const String TYPE_JOB_REQUEST = 'job_request';
  static const String TYPE_JOB_UPDATE = 'job_update';
  static const String TYPE_PAYMENT = 'payment';
  static const String TYPE_REVIEW = 'review';
  static const String TYPE_SYSTEM = 'system';

  const NotificationModel({
    required this.id,
    required this.electricianId,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      electricianId: json['electrician_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: _typeFromString(json['type'] as String),
      read: json['read'] as bool,
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
        return NotificationType.system;
    }
  }

  static String _typeToString(NotificationType type) {
    switch (type) {
      case NotificationType.jobRequest:
        return 'job_request';
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
      'electrician_id': electricianId,
      'title': title,
      'message': message,
      'type': _typeToString(type),
      'read': read,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  NotificationModel copyWith({
    String? id,
    String? electricianId,
    String? title,
    String? message,
    NotificationType? type,
    bool? read,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      electricianId: electricianId ?? this.electricianId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationModel &&
        other.id == id &&
        other.electricianId == electricianId &&
        other.title == title &&
        other.message == message &&
        other.type == type &&
        other.read == read &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        electricianId.hashCode ^
        title.hashCode ^
        message.hashCode ^
        type.hashCode ^
        read.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
