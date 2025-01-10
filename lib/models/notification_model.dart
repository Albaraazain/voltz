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

  // For testing purposes - keeping as reference implementation
  factory NotificationModel.dummy() {
    // TODO: Replace dummy data with real notification data from backend
    // TODO: Add dynamic user information instead of hardcoded "John Doe"
    // TODO: Implement proper notification ID generation
    // TODO: Add proper timestamp handling with user's timezone
    return NotificationModel(
      id: '1', // Reference ID format
      title: 'New Job Request', // Reference title format
      message:
          'You have a new job request from John Doe', // Reference message format
      type: NotificationType.jobRequest,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      relatedId: '123', // Reference related ID format
    );
  }

  // TODO: Implement push notification system
  // TODO: Add notification preferences and settings
  // TODO: Implement notification grouping and categorization
  // TODO: Add rich media notification support
  // TODO: Implement notification analytics
  // TODO: Add scheduled notifications
  // TODO: Implement notification actions (quick replies, accept/reject)
  // TODO: Add offline notification queue
  // TODO: Implement notification sound and vibration settings
  // TODO: Add notification history and archiving
}
