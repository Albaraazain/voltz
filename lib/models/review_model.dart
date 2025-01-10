class ReviewModel {
  final String id;
  final String electricianId;
  final String homeownerId;
  final String jobId;
  final int rating;
  final String? comment;
  final List<String>? photos;
  final String? electricianReply;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    required this.electricianId,
    required this.homeownerId,
    required this.jobId,
    required this.rating,
    this.comment,
    this.photos,
    this.electricianReply,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      electricianId: json['electrician_id'] as String,
      homeownerId: json['homeowner_id'] as String,
      jobId: json['job_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      photos: json['photos'] != null
          ? List<String>.from(json['photos'] as List)
          : null,
      electricianReply: json['electrician_reply'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'electrician_id': electricianId,
      'homeowner_id': homeownerId,
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

  ReviewModel copyWith({
    String? id,
    String? electricianId,
    String? homeownerId,
    String? jobId,
    int? rating,
    String? comment,
    List<String>? photos,
    String? electricianReply,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      electricianId: electricianId ?? this.electricianId,
      homeownerId: homeownerId ?? this.homeownerId,
      jobId: jobId ?? this.jobId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      photos: photos ?? this.photos,
      electricianReply: electricianReply ?? this.electricianReply,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ReviewModel(id: $id, electricianId: $electricianId, homeownerId: $homeownerId, '
        'jobId: $jobId, rating: $rating, comment: $comment, photos: $photos, '
        'electricianReply: $electricianReply, isVerified: $isVerified, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  // For testing purposes - keeping as reference implementation
  factory ReviewModel.dummy() {
    final now = DateTime.now();
    return ReviewModel(
      id: '1',
      electricianId: '123',
      homeownerId: '456',
      jobId: '789',
      rating: 4,
      comment: 'Great service! Very professional and punctual.',
      photos: [],
      electricianReply: 'Thank you for your kind review!',
      isVerified: true,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 1)),
    );
  }
}
