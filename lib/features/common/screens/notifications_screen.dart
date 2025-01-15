import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/notification_model.dart';
import '../../../providers/notification_provider.dart';
import '../widgets/notification_item.dart';

/// Screen that displays a user's notifications.
///
/// This screen shows notifications for both homeowners and electricians using a unified system:
/// - Notifications are fetched based on the user's profile_id
/// - Each notification can be marked as read individually
/// - Notifications are sorted by creation date (newest first)
/// - Different notification types trigger different navigation actions:
///   * job_request -> Job details screen
///   * job_update -> Job details screen
///   * payment -> Payment details screen
///   * review -> Review details screen
///   * system -> Shows a dialog with the notification details
///
/// The screen also provides a "Mark all as read" action in the app bar.
/// Notifications use a visual indicator (light accent color) to show unread status.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final provider = context.read<NotificationProvider>();
    await provider.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Notifications', style: AppTextStyles.h2),
        actions: [
          TextButton(
            onPressed: () {
              context.read<NotificationProvider>().markAllAsRead();
            },
            child: Text(
              'Mark all as read',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          return provider.notifications.when(
            initial: () => const Center(child: Text('No notifications')),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error) => Center(
              child: Text('Error: ${error.message}'),
            ),
            success: (notifications) {
              if (notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _loadNotifications,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: NotificationItem(
                        notification: notification,
                        onTap: () =>
                            _handleNotificationTap(context, notification),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    // Mark notification as read
    context.read<NotificationProvider>().markAsRead(notification.id);

    switch (notification.type) {
      case NotificationType.jobRequest:
        // Navigate to job request details
        Navigator.pushNamed(
          context,
          '/electrician/job-details',
          arguments: {'jobId': notification.relatedId},
        );
        break;
      case NotificationType.jobUpdate:
      case NotificationType.jobAccepted:
      case NotificationType.jobDeclined:
      case NotificationType.jobRejected:
      case NotificationType.jobCompleted:
        // Navigate to job details
        Navigator.pushNamed(
          context,
          '/job-details',
          arguments: {'jobId': notification.relatedId},
        );
        break;
      case NotificationType.message:
        // Navigate to chat
        Navigator.pushNamed(
          context,
          '/chat',
          arguments: {'chatId': notification.relatedId},
        );
        break;
      case NotificationType.review:
        // Navigate to reviews
        Navigator.pushNamed(
          context,
          '/reviews',
          arguments: {'reviewId': notification.relatedId},
        );
        break;
      case NotificationType.payment:
        // Navigate to payment details
        Navigator.pushNamed(
          context,
          '/payment-details',
          arguments: {'paymentId': notification.relatedId},
        );
        break;
      case NotificationType.system:
        // Show system notification details in a dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(notification.title),
            content: Text(notification.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
        break;
    }
  }
}
