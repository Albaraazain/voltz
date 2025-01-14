import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/review_model.dart';
import '../../../providers/review_provider.dart';
import '../../../providers/database_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';

class ReviewsScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final bool canRespond;

  const ReviewsScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.canRespond = false,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  bool _isLoading = false;
  final _responseController = TextEditingController();
  Review? _selectedReview;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);

    try {
      await context.read<ReviewProvider>().loadReviews(
            revieweeId: widget.userId,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load reviews')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showResponseDialog(Review review) async {
    setState(() => _selectedReview = review);
    _responseController.text = review.response?.response ?? '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          review.response == null ? 'Respond to Review' : 'Update Response',
          style: AppTextStyles.h3,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _responseController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your response...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_responseController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a response')),
                );
                return;
              }

              try {
                if (review.response == null) {
                  await context.read<ReviewProvider>().respondToReview(
                        review.id,
                        _responseController.text.trim(),
                      );
                } else {
                  await context.read<ReviewProvider>().updateResponse(
                        review.response!.id,
                        _responseController.text.trim(),
                      );
                }

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Response saved successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to save response')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    setState(() => _selectedReview = null);
  }

  Widget _buildRatingDistribution(Map<int, int> distribution) {
    final total = distribution.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating Distribution',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: 16),
        ...List.generate(5, (index) {
          final rating = 5 - index;
          final count = distribution[rating] ?? 0;
          final percentage = total > 0 ? (count / total * 100) : 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  '$rating',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(width: 8),
                Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: AppColors.border,
                      color: Colors.amber,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(width: 8),
                Text(
                  '($count)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                review.ratingWidget,
                const Spacer(),
                Text(
                  review.formattedDate,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (review.comment != null) ...[
              const SizedBox(height: 16),
              Text(
                review.comment!,
                style: AppTextStyles.bodyMedium,
              ),
            ],
            if (review.response != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Response from ${widget.userName}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          review.response!.formattedDate,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.response!.response,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
            if (widget.canRespond && !review.hasResponse) ...[
              const SizedBox(height: 16),
              CustomButton(
                onPressed: () => _showResponseDialog(review),
                text: 'Respond to Review',
                type: ButtonType.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();
    final reviews = reviewProvider.reviews;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Reviews for ${widget.userName}',
          style: AppTextStyles.h2,
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : reviews.isEmpty
              ? Center(
                  child: Text(
                    'No reviews yet',
                    style: AppTextStyles.bodyLarge,
                  ),
                )
              : ListView.builder(
                  itemCount: reviews.length + 1, // +1 for rating distribution
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: FutureBuilder<Map<int, int>>(
                          future: reviewProvider
                              .getRatingDistribution(widget.userId),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            return _buildRatingDistribution(snapshot.data!);
                          },
                        ),
                      );
                    }
                    return _buildReviewCard(reviews[index - 1]);
                  },
                ),
    );
  }
}
