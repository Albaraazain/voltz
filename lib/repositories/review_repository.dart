import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/api_response.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final SupabaseClient _client;

  ReviewRepository(this._client);

  Future<ApiResponse<List<ReviewModel>>> getReviews(
      String electricianId) async {
    try {
      final response = await _client
          .from('reviews')
          .select()
          .eq('electrician_id', electricianId)
          .order('timestamp', ascending: false);

      final reviews =
          (response as List).map((data) => ReviewModel.fromMap(data)).toList();

      return ApiResponse.success(reviews);
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }

  Future<ApiResponse<ReviewModel>> addReview(ReviewModel review) async {
    try {
      final response = await _client
          .from('reviews')
          .insert(review.toMap())
          .select()
          .single();

      return ApiResponse.success(ReviewModel.fromMap(response));
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }
}
