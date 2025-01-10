/// Represents different types of notifications in the system
enum NotificationType {
  jobRequest,
  jobAccepted,
  jobDeclined,
  jobRejected,
  jobCompleted,
  message,
  review,
}

/// Model class for notifications
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String relatedId;
  final bool isRead;
  final DateTime createdAt;
  final String userId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.relatedId,
    required this.isRead,
    required this.createdAt,
    required this.userId,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${map['type']}',
      ),
      relatedId: map['related_id'] as String,
      isRead: map['is_read'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
      userId: map['user_id'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'related_id': relatedId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    String? relatedId,
    bool? isRead,
    DateTime? createdAt,
    String? userId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
