import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool isInteractive;
  final ValueChanged<double>? onRatingChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 24,
    this.isInteractive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isFilled = starValue <= rating;
        final isHalfFilled = starValue == rating.ceil() && rating % 1 != 0;

        return GestureDetector(
          onTap: isInteractive && onRatingChanged != null
              ? () => onRatingChanged!(starValue.toDouble())
              : null,
          child: Icon(
            isHalfFilled
                ? Icons.star_half
                : isFilled
                    ? Icons.star
                    : Icons.star_border,
            color: AppColors.warning,
            size: size,
          ),
        );
      }),
    );
  }
}
