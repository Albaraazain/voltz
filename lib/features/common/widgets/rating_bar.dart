import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class RatingBar extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final double size;

  const RatingBar({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => onRatingChanged(index + 1.0),
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              index < rating
                  ? Icons.star
                  : Icons.star_border,
              color: Colors.amber,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}