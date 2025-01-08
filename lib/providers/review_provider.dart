import 'package:flutter/foundation.dart';
import '../models/review_model.dart';

class ReviewProvider with ChangeNotifier {
  List<ReviewModel> _reviews = [];
  double _averageRating = 0.0;

  List<ReviewModel> get reviews => _reviews;
  double get averageRating => _averageRating;

  ReviewProvider() {
    // Initialize with dummy data for testing
    _reviews = List.generate(
      5,
      (index) => ReviewModel(
        id: index.toString(),
        userName: 'User ${index + 1}',
        rating: 3 + (index % 3),
        comment: 'This is a test review ${index + 1}. The service was great!',
        timestamp: DateTime.now().subtract(Duration(days: index)),
        photos: [],
        electricianReply: index % 2 == 0 ? 'Thank you for your review!' : null,
      ),
    );
    _calculateAverageRating();
  }

  void _calculateAverageRating() {
    if (_reviews.isEmpty) {
      _averageRating = 0.0;
      return;
    }

    final sum = _reviews.fold<int>(
      0,
      (sum, review) => sum + review.rating,
    );
    _averageRating = sum / _reviews.length;
  }

  Map<int, int> getRatingDistribution() {
    final distribution = <int, int>{};
    for (var i = 1; i <= 5; i++) {
      distribution[i] = _reviews.where((review) => review.rating == i).length;
    }
    return distribution;
  }
}
