import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/review_model.dart';
import '../widgets/rating_stars.dart';
import '../widgets/photo_gallery.dart';

class ReviewDetailsScreen extends StatelessWidget {
  final Review review;

  const ReviewDetailsScreen({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Review Details',
          style: AppTextStyles.h2,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Info
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    review.homeowner?.profile.name.characters.first
                            .toUpperCase() ??
                        'U',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.homeowner?.profile.name ?? 'Unknown User',
                      style: AppTextStyles.h3,
                    ),
                    Text(
                      review.formattedDate,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Rating
            RatingStars(rating: review.rating.toDouble()),
            const SizedBox(height: 16),

            // Review Text
            Text(
              review.comment,
              style: AppTextStyles.bodyLarge,
            ),
            if (review.photos.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Photos',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 16),
              PhotoGallery(photos: review.photos),
            ],

            if (review.job != null) ...[
              const SizedBox(height: 24),
              // Job Details
              Text(
                'Job Details',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildJobDetail(
                      'Service Type',
                      review.job?.title ?? 'N/A',
                      Icons.work_outline,
                    ),
                    const Divider(height: 24),
                    _buildJobDetail(
                      'Date',
                      review.job?.date.toString() ?? 'N/A',
                      Icons.calendar_today_outlined,
                    ),
                    const Divider(height: 24),
                    _buildJobDetail(
                      'Amount',
                      review.job?.price != null
                          ? '\$${review.job!.price.toStringAsFixed(2)}'
                          : 'N/A',
                      Icons.attach_money,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildJobDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.accent,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}
