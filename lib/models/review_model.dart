class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String electricianId;
  final double rating;
  final String? comment;
  final DateTime timestamp;
  final List<String>? photos;
  final String? electricianReply;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.electricianId,
    required this.rating,
    this.comment,
    required this.timestamp,
    this.photos,
    this.electricianReply,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String,
      electricianId: map['electrician_id'] as String,
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      photos: map['photos'] != null ? List<String>.from(map['photos']) : null,
      electricianReply: map['electrician_reply'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'electrician_id': electricianId,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
      'photos': photos,
      'electrician_reply': electricianReply,
    };
  }

  ReviewModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? electricianId,
    double? rating,
    String? comment,
    DateTime? timestamp,
    List<String>? photos,
    String? electricianReply,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      electricianId: electricianId ?? this.electricianId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
      photos: photos ?? this.photos,
      electricianReply: electricianReply ?? this.electricianReply,
    );
  }
}
