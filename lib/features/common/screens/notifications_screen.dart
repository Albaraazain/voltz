import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/notification_provider.dart';
import '../widgets/notification_item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Notifications',
          style: AppTextStyles.h2,
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<NotificationProvider>().markAllAsRead();
            },
            child: Text(
              'Mark all as read',
              style: AppTextStyles.link,
            ),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          final notifications = notificationProvider.notifications;

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
                    'No notifications yet',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationItem(
                notification: notification,
                onTap: () {
                  notificationProvider.markAsRead(notification.id);
                  _handleNotificationTap(context, notification);
                },
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
    switch (notification.type) {
      case NotificationType.newJob:
        // Navigate to job details
        break;
      case NotificationType.jobAccepted:
        // Navigate to active job
        break;
      case NotificationType.jobCompleted:
        // Navigate to completed job
        break;
      case NotificationType.message:
        // Navigate to chat
        break;
      case NotificationType.payment:
        // Navigate to payment details
        break;
      case NotificationType.review:
        // Navigate to reviews
        break;
    }
  }
}