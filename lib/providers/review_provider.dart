import 'package:flutter/foundation.dart';
import '../models/review_model.dart';

class ReviewProvider with ChangeNotifier {
  final List<ReviewModel> _reviews = [];
  double _averageRating = 0;

  List<ReviewModel> get reviews => _reviews;
  double get averageRating => _averageRating;

  void addReview(ReviewModel review) {
    _reviews.insert(0, review);
    _calculateAverageRating();
    notifyListeners();
  }

  void addElectricianReply(String reviewId, String reply) {
    final reviewIndex = _reviews.indexWhere((r) => r.id == reviewId);
    if (reviewIndex != -1) {
      // In a real app, we'd create a new ReviewModel with the reply
      notifyListeners();
    }
  }

  void _calculateAverageRating() {
    if (_reviews.isEmpty) {
      _averageRating = 0;
      return;
    }

    double sum = 0;
    for (var review in _reviews) {
      sum += review.rating;
    }
    _averageRating = sum / _reviews.length;
  }

  Map<int, int> getRatingDistribution() {
    Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in _reviews) {
      distribution[review.rating.round()] =
          (distribution[review.rating.round()] ?? 0) + 1;
    }
    return distribution;
  }
}