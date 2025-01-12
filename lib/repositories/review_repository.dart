import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../core/services/logger_service.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<Review>> getReviews({String? electricianId}) async {
    try {
      final query = _client.from('reviews').select('''
        *,
        homeowner:homeowners (
          id,
          profile:profiles (
            id,
            email,
            user_type,
            name,
            created_at,
            last_login_at
          )
        ),
        electrician:electricians (
          id,
          profile:profiles (
            id,
            email,
            user_type,
            name,
            created_at,
            last_login_at
          )
        )
      ''');

      if (electricianId != null) {
        query.eq('electrician_id', electricianId);
      }

      final response = await query.order('created_at', ascending: false);
      return response.map((data) => Review.fromJson(data)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get reviews', e, stackTrace);
      rethrow;
    }
  }

  Future<void> addReview(Review review) async {
    try {
      await _client.from('reviews').insert(review.toJson());
    } catch (e, stackTrace) {
      LoggerService.error('Failed to add review', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateReview(Review review) async {
    try {
      await _client.from('reviews').update(review.toJson()).eq('id', review.id);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update review', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _client.from('reviews').delete().eq('id', reviewId);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to delete review', e, stackTrace);
      rethrow;
    }
  }
}
