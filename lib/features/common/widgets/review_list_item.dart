import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/review_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewListItem extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback onTap;

  const ReviewListItem({
    super.key,
    required this.review,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.person,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            size: 16,
                            color: index < review.rating
                                ? Colors.amber
                                : AppColors.border,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                Text(
                  timeago.format(review.timestamp),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.comment,
                style: AppTextStyles.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
