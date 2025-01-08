import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../common/widgets/custom_button.dart';

class JobRequestCard extends StatelessWidget {
  final String customerName;
  final String jobType;
  final String date;
  final String address;
  final String description;
  final String status;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onReschedule;

  const JobRequestCard({
    super.key,
    required this.customerName,
    required this.jobType,
    required this.date,
    required this.address,
    required this.description,
    required this.status,
    required this.onAccept,
    required this.onDecline,
    required this.onReschedule,
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
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName,
                            style: AppTextStyles.h3,
                          ),
                          Text(
                            jobType,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      date,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      address,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  description,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: status == 'new'
                ? Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          onPressed: onDecline,
                          text: 'Decline',
                          type: ButtonType.secondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          onPressed: onAccept,
                          text: 'Accept',
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          onPressed: onReschedule,
                          text: 'Reschedule',
                          type: ButtonType.secondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}