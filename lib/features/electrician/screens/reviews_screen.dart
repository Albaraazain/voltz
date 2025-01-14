import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/review_provider.dart';
import '../../../models/review_model.dart';
import '../../common/widgets/review_list_item.dart';
import '../../common/widgets/loading_indicator.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviews();
    });
  }

  Future<void> _loadReviews() async {
    final dbProvider = context.read<DatabaseProvider>();
    final reviewProvider = context.read<ReviewProvider>();

    if (dbProvider.currentProfile == null) return;

    final electrician = dbProvider.electricians.firstWhere(
      (e) => e.profile.id == dbProvider.currentProfile!.id,
    );

    await reviewProvider.getReviewsForElectrician(electrician.id);
  }

  Widget _buildStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.accent,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.h3,
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'My Reviews',
          style: AppTextStyles.h2,
        ),
        elevation: 0,
      ),
      body: Consumer2<DatabaseProvider, ReviewProvider>(
        builder: (context, dbProvider, reviewProvider, child) {
          if (dbProvider.isLoading || reviewProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (dbProvider.currentProfile == null) {
            return const Center(
              child: Text('Please log in to view your reviews'),
            );
          }

          final electrician = dbProvider.electricians.firstWhere(
            (e) => e.profile.id == dbProvider.currentProfile!.id,
          );

          final reviews = reviewProvider.reviews;

          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Reviews Yet',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete jobs to get reviews from customers',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Stats Section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(
                        electrician.rating.toStringAsFixed(1),
                        'Average Rating',
                        Icons.star,
                      ),
                      _buildStat(
                        reviews.length.toString(),
                        'Total Reviews',
                        Icons.reviews,
                      ),
                      _buildStat(
                        '${(reviews.where((r) => r.rating >= 4).length * 100 / reviews.length).toStringAsFixed(0)}%',
                        'Satisfaction',
                        Icons.thumb_up,
                      ),
                    ],
                  ),
                ),
              ),

              // Reviews List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final review = reviews[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ReviewListItem(
                          review: review,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/review-details',
                              arguments: review,
                            );
                          },
                        ),
                      );
                    },
                    childCount: reviews.length,
                  ),
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          );
        },
      ),
    );
  }
}
