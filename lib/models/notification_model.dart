/// Represents different types of notifications in the system
enum NotificationType {
  jobRequest,
  jobAccepted,
  jobCompleted,
  jobCancelled,
  payment,
  review,
  message,
  system
}

/// Model class for notifications
class NotificationModel {
  final String id;
  final String profileId;
  final String title;
  final String message;
  final NotificationType type;
  final String? relatedId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.profileId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.system,
      ),
      relatedId: json['related_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'related_id': relatedId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? profileId,
    String? title,
    String? message,
    NotificationType? type,
    String? relatedId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, profileId: $profileId, title: $title, '
        'message: $message, type: $type, relatedId: $relatedId, '
        'isRead: $isRead, createdAt: $createdAt)';
  }

  // For testing purposes
  factory NotificationModel.dummy() {
    return NotificationModel(
      id: '1',
      profileId: '123',
      title: 'New Job Request',
      message: 'You have a new job request in your area',
      type: NotificationType.jobRequest,
      relatedId: '456',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    );
  }
}
