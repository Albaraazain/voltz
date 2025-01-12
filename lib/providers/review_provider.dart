import 'package:flutter/foundation.dart';
import '../core/services/logger_service.dart';
import '../models/review_model.dart';
import '../repositories/review_repository.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewRepository _repository;
  List<Review> _reviews = [];
  bool _isLoading = false;

  ReviewProvider(this._repository);

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;

  Future<void> loadReviews({String? electricianId}) async {
    try {
      _isLoading = true;
      notifyListeners();

      _reviews = await _repository.getReviews(electricianId: electricianId);

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      LoggerService.error('Failed to load reviews', e, stackTrace);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addReview(Review review) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.addReview(review);
      await loadReviews(electricianId: review.electrician.id);

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      LoggerService.error('Failed to add review', e, stackTrace);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateReview(Review review) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.updateReview(review);
      await loadReviews(electricianId: review.electrician.id);

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      LoggerService.error('Failed to update review', e, stackTrace);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.deleteReview(reviewId);
      await loadReviews();

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      LoggerService.error('Failed to delete review', e, stackTrace);
      notifyListeners();
      rethrow;
    }
  }

  List<Review> getReviewsForElectrician(String electricianId) {
    return reviews
        .where((review) => review.electrician.id == electricianId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
