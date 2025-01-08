import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/review_provider.dart';
import '../widgets/rating_distribution.dart';
import '../widgets/review_list_item.dart';

class ReviewsListScreen extends StatelessWidget {
  final String electricianId;
  final String electricianName;

  const ReviewsListScreen({
    super.key,
    required this.electricianId,
    required this.electricianName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Reviews & Ratings',
          style: AppTextStyles.h2,
        ),
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, reviewProvider, child) {
          final reviews = reviewProvider.reviews;
          final averageRating = reviewProvider.averageRating;
          final ratingDistribution = reviewProvider.getRatingDistribution();

          return CustomScrollView(
            slivers: [
              // Rating Summary
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: AppTextStyles.h1.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    Icons.star,
                                    size: 16,
                                    color: index < averageRating.floor()
                                        ? Colors.amber
                                        : AppColors.border,
                                  );
                                }),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${reviews.length} reviews',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      RatingDistribution(distribution: ratingDistribution),
                    ],
                  ),
                ),
              ),

              // Reviews List
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final review = reviews[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ReviewListItem(
                          review: review,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReviewDetailsScreen(
                                  review: review,
                                  electricianName: electricianName,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: reviews.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}