enum NotificationType {
  jobRequest,
  jobAccepted,
  jobRejected,
  jobCompleted,
  review,
  message,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.relatedId,
  });

  // For testing purposes
  factory NotificationModel.dummy() {
    return NotificationModel(
      id: '1',
      title: 'New Job Request',
      message: 'You have a new job request from John Doe',
      type: NotificationType.jobRequest,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      relatedId: '123',
    );
  }
}
