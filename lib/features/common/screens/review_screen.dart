import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../common/widgets/custom_button.dart';
import '../widgets/rating_bar.dart';
import '../widgets/photo_picker.dart';

class ReviewScreen extends StatefulWidget {
  final String jobId;
  final String electricianId;
  final String electricianName;

  const ReviewScreen({
    super.key,
    required this.jobId,
    required this.electricianId,
    required this.electricianName,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _commentController = TextEditingController();
  double _rating = 0;
  List<String> _selectedPhotos = [];
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Write a Review',
          style: AppTextStyles.h2,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How was your experience with ${widget.electricianName}?',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 24),
            // Rating
            Center(
              child: Column(
                children: [
                  RatingBar(
                    rating: _rating,
                    onRatingChanged: (value) {
                      setState(() {
                        _rating = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getRatingText(),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Comment
            Text(
              'Share your experience',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 5,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Write your review here...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Photo Upload
            Text(
              'Add Photos',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            PhotoPicker(
              selectedPhotos: _selectedPhotos,
              onPhotosSelected: (photos) {
                setState(() {
                  _selectedPhotos = photos;
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomButton(
            onPressed: _rating > 0 ? _submitReview : null,
            text: 'Submit Review',
            isLoading: _isSubmitting,
          ),
        ),
      ),
    );
  }

  String _getRatingText() {
    if (_rating == 0) return 'Select Rating';
    if (_rating <= 1) return 'Poor';
    if (_rating <= 2) return 'Fair';
    if (_rating <= 3) return 'Good';
    if (_rating <= 4) return 'Very Good';
    return 'Excellent';
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Submit review to provider/backend
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}