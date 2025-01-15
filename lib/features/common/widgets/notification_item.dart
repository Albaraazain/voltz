import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/notification_model.dart';
import 'package:provider/provider.dart';
import '../../../providers/notification_provider.dart';

/// A widget that displays a single notification item.
///
/// Features:
/// - Shows notification title, message, and timestamp
/// - Visual indicator for unread notifications (light accent color background)
/// - Automatically marks notification as read when tapped
/// - Uses timeago to display relative time (e.g., "2 hours ago")
/// - Displays appropriate icon based on notification type
class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  /// Returns the appropriate icon based on the notification type
  IconData _getNotificationIcon() {
    switch (notification.type) {
      case NotificationType.jobRequest:
        return Icons.work_outline;
      case NotificationType.jobUpdate:
      case NotificationType.jobAccepted:
      case NotificationType.jobDeclined:
      case NotificationType.jobRejected:
      case NotificationType.jobCompleted:
        return Icons.engineering;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.review:
        return Icons.star_outline;
      case NotificationType.message:
        return Icons.message_outlined;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!notification.read) {
          // Mark as read using the provider
          Provider.of<NotificationProvider>(context, listen: false)
              .markAsRead(notification.id);
        }
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.read
              ? AppColors.surface
              : AppColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _getNotificationIcon(),
              color: AppColors.accent,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeago.format(notification.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
