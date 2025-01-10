import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/review_provider.dart';
import '../widgets/review_list_item.dart';
import 'review_details_screen.dart';

class ReviewsListScreen extends StatefulWidget {
  final String electricianId;

  const ReviewsListScreen({
    super.key,
    required this.electricianId,
  });

  @override
  State<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends State<ReviewsListScreen> {
  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final provider = context.read<ReviewProvider>();
    await provider.loadReviews(widget.electricianId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Reviews', style: AppTextStyles.h2),
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, provider, child) {
          return provider.reviews.when(
            initial: () => const Center(child: Text('No reviews yet')),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error) => Center(
              child: Text('Error: ${error.message}'),
            ),
            success: (reviews) {
              if (reviews.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_border,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No reviews yet',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _loadReviews,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: reviews.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return ReviewListItem(
                      review: review,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ReviewDetailsScreen(review: review),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
