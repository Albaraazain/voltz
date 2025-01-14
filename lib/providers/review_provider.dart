import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/logger_service.dart';
import '../core/services/notification_service.dart';
import '../models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  final SupabaseClient _client;
  bool _isLoading = false;
  List<Review> _reviews = [];
  String? _error;

  ReviewProvider(this._client);

  bool get isLoading => _isLoading;
  List<Review> get reviews => _reviews;
  String? get error => _error;

  // Load reviews with filters
  Future<void> loadReviews({
    String? jobId,
    String? reviewerId,
    String? revieweeId,
    String? reviewerType,
    int? minRating,
    int? maxRating,
    bool ascending = false,
    int? limit,
    int? offset,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      dynamic query = _client.from('reviews').select('''
        *,
        response:review_responses (
          id,
          review_id,
          response,
          created_at,
          updated_at
        )
      ''');

      // Apply filters
      if (jobId != null) {
        query = query.eq('job_id', jobId);
      }
      if (reviewerId != null) {
        query = query.eq('reviewer_id', reviewerId);
      }
      if (revieweeId != null) {
        query = query.eq('reviewee_id', revieweeId);
      }
      if (reviewerType != null) {
        query = query.eq('reviewer_type', reviewerType);
      }
      if (minRating != null) {
        query = query.gte('rating', minRating);
      }
      if (maxRating != null) {
        query = query.lte('rating', maxRating);
      }

      // Apply ordering
      query = query.order('created_at', ascending: ascending);

      // Apply pagination
      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;
      _reviews = response.map<Review>((json) => Review.fromJson(json)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Error loading reviews', e, stackTrace);
      _error = 'Failed to load reviews';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new review
  Future<Review> createReview(Review review) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('reviews')
          .insert(review.toJson())
          .select()
          .single();

      final newReview = Review.fromJson(response);
      _reviews.insert(0, newReview);

      // Create notification for reviewee
      await _client.from('notifications').insert({
        'user_id': review.revieweeId,
        'title': 'New Review',
        'message': 'You have received a new ${review.rating}-star review',
        'type': 'REVIEW',
        'read': false,
      });

      // Show local notification
      await NotificationService.showNotification(
        title: 'Review Submitted',
        body: 'Your review has been submitted successfully',
        payload: 'review_${newReview.id}',
      );

      notifyListeners();
      return newReview;
    } catch (e, stackTrace) {
      LoggerService.error('Error creating review', e, stackTrace);
      _error = 'Failed to create review';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing review
  Future<Review> updateReview(
    String reviewId, {
    int? rating,
    String? comment,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('reviews')
          .update({
            if (rating != null) 'rating': rating,
            if (comment != null) 'comment': comment,
          })
          .eq('id', reviewId)
          .select()
          .single();

      final updatedReview = Review.fromJson(response);
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        _reviews[index] = updatedReview;
      }

      notifyListeners();
      return updatedReview;
    } catch (e, stackTrace) {
      LoggerService.error('Error updating review', e, stackTrace);
      _error = 'Failed to update review';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a review
  Future<void> deleteReview(String reviewId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client.from('reviews').delete().eq('id', reviewId);
      _reviews.removeWhere((review) => review.id == reviewId);
    } catch (e, stackTrace) {
      LoggerService.error('Error deleting review', e, stackTrace);
      _error = 'Failed to delete review';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a response to a review
  Future<ReviewResponse> respondToReview(
      String reviewId, String response) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final responseData = await _client
          .from('review_responses')
          .insert({
            'review_id': reviewId,
            'response': response,
          })
          .select()
          .single();

      final newResponse = ReviewResponse.fromJson(responseData);
      final reviewIndex = _reviews.indexWhere((r) => r.id == reviewId);
      if (reviewIndex != -1) {
        _reviews[reviewIndex] = _reviews[reviewIndex].copyWith(
          response: newResponse,
        );
      }

      // Create notification for reviewer
      final review = _reviews.firstWhere((r) => r.id == reviewId);
      await _client.from('notifications').insert({
        'user_id': review.reviewerId,
        'title': 'Review Response',
        'message': 'Your review has received a response',
        'type': 'REVIEW_RESPONSE',
        'read': false,
      });

      notifyListeners();
      return newResponse;
    } catch (e, stackTrace) {
      LoggerService.error('Error responding to review', e, stackTrace);
      _error = 'Failed to respond to review';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update a review response
  Future<ReviewResponse> updateResponse(
      String responseId, String newResponse) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final responseData = await _client
          .from('review_responses')
          .update({'response': newResponse})
          .eq('id', responseId)
          .select()
          .single();

      final updatedResponse = ReviewResponse.fromJson(responseData);
      final reviewIndex =
          _reviews.indexWhere((r) => r.response?.id == responseId);
      if (reviewIndex != -1) {
        _reviews[reviewIndex] = _reviews[reviewIndex].copyWith(
          response: updatedResponse,
        );
      }

      notifyListeners();
      return updatedResponse;
    } catch (e, stackTrace) {
      LoggerService.error('Error updating review response', e, stackTrace);
      _error = 'Failed to update response';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a review response
  Future<void> deleteResponse(String responseId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client.from('review_responses').delete().eq('id', responseId);
      final reviewIndex =
          _reviews.indexWhere((r) => r.response?.id == responseId);
      if (reviewIndex != -1) {
        _reviews[reviewIndex] = _reviews[reviewIndex].copyWith(response: null);
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error deleting review response', e, stackTrace);
      _error = 'Failed to delete response';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get average rating for a user
  Future<double> getAverageRating(String userId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('rating')
          .eq('reviewee_id', userId);

      final ratings = response.map<int>((r) => r['rating'] as int).toList();
      if (ratings.isEmpty) return 0;
      return ratings.reduce((a, b) => a + b) / ratings.length;
    } catch (e, stackTrace) {
      LoggerService.error('Error getting average rating', e, stackTrace);
      rethrow;
    }
  }

  // Get rating distribution for a user
  Future<Map<int, int>> getRatingDistribution(String userId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('rating')
          .eq('reviewee_id', userId);

      final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (final review in response) {
        final rating = review['rating'] as int;
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }
      return distribution;
    } catch (e, stackTrace) {
      LoggerService.error('Error getting rating distribution', e, stackTrace);
      rethrow;
    }
  }

  // Get reviews for a specific electrician
  Future<List<Review>> getReviewsForElectrician(String electricianId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('reviews')
          .select('''
            *,
            response:review_responses (
              id,
              review_id,
              response,
              created_at,
              updated_at
            ),
            homeowner:homeowners (
              id,
              profile:profiles (
                id,
                name,
                email,
                phone,
                avatar_url
              )
            ),
            job:jobs (
              id,
              title,
              description,
              service_type,
              status,
              date,
              amount
            )
          ''')
          .eq('reviewee_id', electricianId)
          .eq('reviewer_type', Review.TYPE_HOMEOWNER)
          .order('created_at', ascending: false);

      _reviews = response.map<Review>((json) => Review.fromJson(json)).toList();
      return _reviews;
    } catch (e, stackTrace) {
      LoggerService.error('Error loading electrician reviews', e, stackTrace);
      _error = 'Failed to load electrician reviews';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all data (useful when logging out)
  void clear() {
    _reviews = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
