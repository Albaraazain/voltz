import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/repositories/base_repository.dart';
import '../core/utils/api_response.dart';
import '../models/review_model.dart';

class ReviewRepository extends BaseRepository<ReviewModel> {
  ReviewRepository(SupabaseClient supabase) : super(supabase, 'reviews');

  @override
  ReviewModel fromJson(Map<String, dynamic> json) => ReviewModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(ReviewModel entity) => entity.toJson();

  /// Get reviews for a specific electrician
  Future<ApiResponse<List<ReviewModel>>> getElectricianReviews(
    String electricianId, {
    int? limit,
    int? offset,
  }) async {
    return list(
      filters: {'electrician_id': electricianId},
      orderBy: 'created_at',
      ascending: false,
      limit: limit,
      offset: offset,
    );
  }

  /// Get average rating for an electrician
  Future<ApiResponse<double>> getElectricianAverageRating(
    String electricianId,
  ) async {
    try {
      final response = await supabase
          .from(table)
          .select('rating')
          .eq('electrician_id', electricianId);

      if (response.isEmpty) {
        return ApiResponse.success(0.0);
      }

      final ratings =
          (response as List).map((r) => r['rating'] as int).toList();
      final average = ratings.reduce((a, b) => a + b) / ratings.length;

      return ApiResponse.success(average);
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }

  /// Add electrician's reply to a review
  Future<ApiResponse<ReviewModel>> addElectricianReply(
    String reviewId,
    String reply,
  ) async {
    return customMutation((client) async {
      final response = await client
          .from(table)
          .update({'electrician_reply': reply})
          .eq('id', reviewId)
          .select()
          .single();
      return response;
    });
  }

  /// Get pending (unverified) reviews
  Future<ApiResponse<List<ReviewModel>>> getPendingReviews() async {
    return list(
      filters: {'is_verified': false},
      orderBy: 'created_at',
      ascending: true,
    );
  }

  /// Verify a review
  Future<ApiResponse<ReviewModel>> verifyReview(String reviewId) async {
    return customMutation((client) async {
      final response = await client
          .from(table)
          .update({'is_verified': true})
          .eq('id', reviewId)
          .select()
          .single();
      return response;
    });
  }

  /// Get reviews for a specific job
  Future<ApiResponse<List<ReviewModel>>> getJobReviews(String jobId) async {
    return list(
      filters: {'job_id': jobId},
      orderBy: 'created_at',
      ascending: false,
    );
  }

  /// Stream new reviews for an electrician
  Stream<ApiResponse<List<ReviewModel>>> streamElectricianReviews(
    String electricianId,
  ) {
    return stream(
      filters: {'electrician_id': electricianId},
      orderBy: 'created_at',
      ascending: false,
    );
  }

  /// Get review statistics for an electrician
  Future<ApiResponse<Map<String, dynamic>>> getElectricianReviewStats(
    String electricianId,
  ) async {
    try {
      final response = await supabase
          .from(table)
          .select('rating')
          .eq('electrician_id', electricianId);

      if (response.isEmpty) {
        return ApiResponse.success({
          'average_rating': 0.0,
          'total_reviews': 0,
          'rating_distribution': {
            '1': 0,
            '2': 0,
            '3': 0,
            '4': 0,
            '5': 0,
          },
        });
      }

      final ratings =
          (response as List).map((r) => r['rating'] as int).toList();
      final distribution = {
        '1': 0,
        '2': 0,
        '3': 0,
        '4': 0,
        '5': 0,
      };

      for (final rating in ratings) {
        distribution[rating.toString()] =
            (distribution[rating.toString()] ?? 0) + 1;
      }

      return ApiResponse.success({
        'average_rating': ratings.reduce((a, b) => a + b) / ratings.length,
        'total_reviews': ratings.length,
        'rating_distribution': distribution,
      });
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }
}
