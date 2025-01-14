import 'package:flutter/material.dart';
import 'job_model.dart';
import 'homeowner_model.dart';

class Review {
  final String id;
  final String jobId;
  final String reviewerId;
  final String revieweeId;
  final String reviewerType;
  final int rating;
  final String comment;
  final ReviewResponse? response;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> photos;
  final Job? job;
  final Homeowner? homeowner;

  static const String TYPE_HOMEOWNER = 'HOMEOWNER';
  static const String TYPE_ELECTRICIAN = 'ELECTRICIAN';

  const Review({
    required this.id,
    required this.jobId,
    required this.reviewerId,
    required this.revieweeId,
    required this.reviewerType,
    required this.rating,
    required this.comment,
    this.response,
    required this.createdAt,
    required this.updatedAt,
    this.photos = const [],
    this.job,
    this.homeowner,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      jobId: json['job_id'],
      reviewerId: json['reviewer_id'],
      revieweeId: json['reviewee_id'],
      reviewerType: json['reviewer_type'],
      rating: json['rating'],
      comment: json['comment'] ?? '',
      response: json['response'] != null
          ? ReviewResponse.fromJson(json['response'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      photos:
          json['photos'] != null ? List<String>.from(json['photos']) : const [],
      job: json['job'] != null ? Job.fromJson(json['job']) : null,
      homeowner: json['homeowner'] != null
          ? Homeowner.fromJson(json['homeowner'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'reviewer_id': reviewerId,
      'reviewee_id': revieweeId,
      'reviewer_type': reviewerType,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Review copyWith({
    String? id,
    String? jobId,
    String? reviewerId,
    String? revieweeId,
    String? reviewerType,
    int? rating,
    String? comment,
    ReviewResponse? response,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? photos,
    Job? job,
    Homeowner? homeowner,
  }) {
    return Review(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      reviewerId: reviewerId ?? this.reviewerId,
      revieweeId: revieweeId ?? this.revieweeId,
      reviewerType: reviewerType ?? this.reviewerType,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      response: response ?? this.response,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photos: photos ?? this.photos,
      job: job ?? this.job,
      homeowner: homeowner ?? this.homeowner,
    );
  }

  // Helper methods
  bool get isHomeownerReview => reviewerType == TYPE_HOMEOWNER;
  bool get isElectricianReview => reviewerType == TYPE_ELECTRICIAN;
  bool get hasResponse => response != null;

  // Get star rating widget
  Widget get ratingWidget {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  // Get formatted creation date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
    }
  }
}

class ReviewResponse {
  final String id;
  final String reviewId;
  final String response;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReviewResponse({
    required this.id,
    required this.reviewId,
    required this.response,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      id: json['id'],
      reviewId: json['review_id'],
      response: json['response'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'review_id': reviewId,
      'response': response,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ReviewResponse copyWith({
    String? id,
    String? reviewId,
    String? response,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewResponse(
      id: id ?? this.id,
      reviewId: reviewId ?? this.reviewId,
      response: response ?? this.response,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get formatted creation date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
    }
  }
}
