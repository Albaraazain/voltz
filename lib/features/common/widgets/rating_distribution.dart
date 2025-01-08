import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class RatingDistribution extends StatelessWidget {
  final Map<int, int> distribution;

  const RatingDistribution({
    super.key,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    final maxCount = distribution.values
        .fold<int>(0, (max, count) => count > max ? count : max);

    return Column(
      children: List.generate(5, (index) {
        final rating = 5 - index;
        final count = distribution[rating] ?? 0;
        final percentage = maxCount > 0 ? count / maxCount : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$rating',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.star,
                size: 16,
                color: Colors.amber,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: AppColors.border,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 32,
                child: Text(
                  count.toString(),
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
