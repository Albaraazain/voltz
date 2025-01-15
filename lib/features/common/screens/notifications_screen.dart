import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/notification_model.dart';
import '../../../providers/notification_provider.dart';
import '../widgets/notification_item.dart';

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
          arguments: {'jobId': notification.id},
        );
        break;
      case NotificationType.jobAccepted:
        // Navigate to active job
        Navigator.pushNamed(
          context,
          '/job-details',
          arguments: {'jobId': notification.id},
        );
        break;
      case NotificationType.jobDeclined:
      case NotificationType.jobRejected:
        // Navigate to rejected job details
        Navigator.pushNamed(
          context,
          '/job-details',
          arguments: {'jobId': notification.id},
        );
        break;
      case NotificationType.jobCompleted:
        // Navigate to completed job
        Navigator.pushNamed(
          context,
          '/job-details',
          arguments: {'jobId': notification.id},
        );
        break;
      case NotificationType.message:
        // Navigate to chat
        Navigator.pushNamed(
          context,
          '/chat',
          arguments: {'chatId': notification.id},
        );
        break;
      case NotificationType.review:
        // Navigate to reviews
        Navigator.pushNamed(
          context,
          '/reviews',
          arguments: {'reviewId': notification.id},
        );
        break;
      case NotificationType.payment:
        // Navigate to payment details
        Navigator.pushNamed(
          context,
          '/payment-details',
          arguments: {'paymentId': notification.id},
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
