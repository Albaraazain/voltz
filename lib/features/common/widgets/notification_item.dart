import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/notification_model.dart';
import 'package:provider/provider.dart';
import '../../../providers/notification_provider.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
  });

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
            _buildIcon(),
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

  Widget _buildIcon() {
    late IconData icon;
    late Color color;

    switch (notification.type) {
      case NotificationType.jobRequest:
        icon = Icons.work_outline;
        color = AppColors.primary;
        break;
      case NotificationType.jobAccepted:
        icon = Icons.check_circle_outline;
        color = AppColors.success;
        break;
      case NotificationType.jobDeclined:
      case NotificationType.jobRejected:
        icon = Icons.cancel_outlined;
        color = AppColors.error;
        break;
      case NotificationType.jobCompleted:
        icon = Icons.task_alt;
        color = AppColors.success;
        break;
      case NotificationType.message:
        icon = Icons.chat_bubble_outline;
        color = AppColors.accent;
        break;
      case NotificationType.review:
        icon = Icons.star_outline;
        color = AppColors.warning;
        break;
      case NotificationType.payment:
        icon = Icons.payment_outlined;
        color = AppColors.success;
        break;
      case NotificationType.system:
        icon = Icons.info_outline;
        color = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }
}
