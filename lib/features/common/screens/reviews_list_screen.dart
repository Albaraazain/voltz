import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/review_provider.dart';
import '../widgets/review_list_item.dart';
import '../widgets/loading_indicator.dart';
import 'review_details_screen.dart';

class ReviewsListScreen extends StatelessWidget {
  final String? electricianId;

  const ReviewsListScreen({
    super.key,
    this.electricianId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reviews'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, reviewProvider, child) {
          if (reviewProvider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          final reviews = reviewProvider.reviews;

          if (reviews.isEmpty) {
            return Center(
              child: Text(
                'No reviews yet',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final review = reviews[index];
              return ReviewListItem(
                review: review,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewDetailsScreen(review: review),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
