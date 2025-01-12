import 'package:flutter/material.dart';
import 'homeowner_model.dart';
import 'electrician_model.dart';
import 'profile_model.dart';

class Review {
  final String id;
  final Electrician electrician;
  final Homeowner homeowner;
  final String jobId;
  final int rating;
  final String comment;
  final List<String> photos;
  final String? electricianReply;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.electrician,
    required this.homeowner,
    required this.jobId,
    required this.rating,
    required this.comment,
    this.photos = const [],
    this.electricianReply,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    final homeownerData = map['homeowner'] as Map<String, dynamic>;
    final homeownerProfile =
        Profile.fromMap(homeownerData['profile'] as Map<String, dynamic>);

    final electricianData = map['electrician'] as Map<String, dynamic>;
    final electricianProfile =
        Profile.fromMap(electricianData['profile'] as Map<String, dynamic>);

    return Review(
      id: map['id'] as String,
      electrician: Electrician.fromMap(
        electricianData,
        profile: electricianProfile,
      ),
      homeowner: Homeowner.fromMap(
        homeownerData,
        profile: homeownerProfile,
      ),
      jobId: map['job_id'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String,
      photos:
          (map['photos'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      electricianReply: map['electrician_reply'] as String?,
      isVerified: map['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'electrician_id': electrician.id,
      'homeowner_id': homeowner.id,
      'job_id': jobId,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'electrician_reply': electricianReply,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
