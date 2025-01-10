import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/api_response.dart';
import '../models/review_model.dart';
import '../repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _repository;
  ApiResponse<List<ReviewModel>> _reviews = ApiResponse.initial();
  double _averageRating = 0.0;
  Map<int, int> _ratingDistribution = {};

  ReviewProvider(this._repository);

  ApiResponse<List<ReviewModel>> get reviews => _reviews;
  double get averageRating => _averageRating;
  Map<int, int> get ratingDistribution => _ratingDistribution;

  Future<void> loadReviews(String electricianId) async {
    _reviews = ApiResponse.loading();
    notifyListeners();

    _reviews = await _repository.getReviews(electricianId);
    if (_reviews.hasData) {
      _calculateStats();
    }
    notifyListeners();
  }

  void _calculateStats() {
    if (!_reviews.hasData) return;

    final reviews = _reviews.data!;
    if (reviews.isEmpty) {
      _averageRating = 0.0;
      _ratingDistribution = {};
      return;
    }

    // Calculate average rating
    double sum = 0;
    _ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (final review in reviews) {
      sum += review.rating;
      final rating = review.rating.round();
      _ratingDistribution[rating] = (_ratingDistribution[rating] ?? 0) + 1;
    }

    _averageRating = sum / reviews.length;
  }

  Future<void> addReview({
    required String electricianId,
    required String userId,
    required String userName,
    required double rating,
    String? comment,
  }) async {
    final review = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: userName,
      electricianId: electricianId,
      rating: rating,
      comment: comment,
      timestamp: DateTime.now(),
    );

    final response = await _repository.addReview(review);
    if (response.hasData) {
      if (_reviews.hasData) {
        final updatedReviews = List<ReviewModel>.from(_reviews.data!)
          ..add(response.data!);
        _reviews = ApiResponse.success(updatedReviews);
        _calculateStats();
        notifyListeners();
      }
    }
  }

  Map<int, int> getRatingDistribution() {
    return _ratingDistribution;
  }
}
