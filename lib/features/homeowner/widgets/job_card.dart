import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class JobCard extends StatelessWidget {
  final String jobType;
  final String jobTitle;
  final String electricianName;
  final String date;
  final String status;
  final String amount;

  const JobCard({
    super.key,
    required this.jobType,
    required this.jobTitle,
    required this.electricianName,
    required this.date,
    required this.status,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Main Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.electrical_services,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                // Job Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jobTitle,
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by $electricianName',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.calendar_today_outlined,
                            label: date,
                          ),
                          const SizedBox(width: 8),
                          _StatusChip(status: status),
                        ],
                      ),
                    ],
                  ),
                ),
                // Amount
                Text(
                  amount,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                if (jobType == 'active') ...[
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.message_outlined,
                      label: 'Message',
                      onPressed: () {
                        // TODO: Open chat
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      onPressed: () {
                        // TODO: Show location
                      },
                    ),
                  ),
                ] else if (jobType == 'scheduled') ...[
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.edit_calendar_outlined,
                      label: 'Reschedule',
                      onPressed: () {
                        // TODO: Reschedule job
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.cancel_outlined,
                      label: 'Cancel',
                      onPressed: () {
                        // TODO: Cancel job
                      },
                      isDestructive: true,
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.rate_review_outlined,
                      label: 'Leave Review',
                      onPressed: () {
                        // TODO: Open review dialog
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.receipt_long_outlined,
                      label: 'View Receipt',
                      onPressed: () {
                        // TODO: Show receipt
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : AppColors.accent;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.buttonMedium.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}