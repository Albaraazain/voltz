import 'package:flutter/material.dart';
import 'homeowner_model.dart';
import 'electrician_model.dart';
import 'job_model.dart';

class Review {
  final String id;
  final Homeowner homeowner;
  final Electrician electrician;
  final Job job;
  final int rating;
  final String comment;
  final List<String> photos;
  final DateTime createdAt;
  final String? electricianReply;

  const Review({
    required this.id,
    required this.homeowner,
    required this.electrician,
    required this.job,
    required this.rating,
    required this.comment,
    this.photos = const [],
    required this.createdAt,
    this.electricianReply,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homeowner': homeowner.toJson(),
      'electrician': electrician.toJson(),
      'job': job.toJson(),
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'createdAt': createdAt.toIso8601String(),
      'electricianReply': electricianReply,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      homeowner: Homeowner.fromJson(json['homeowner']),
      electrician: Electrician.fromJson(json['electrician']),
      job: Job.fromJson(json['job']),
      rating: json['rating'],
      comment: json['comment'],
      photos: List<String>.from(json['photos']),
      createdAt: DateTime.parse(json['createdAt']),
      electricianReply: json['electricianReply'],
    );
  }
}
