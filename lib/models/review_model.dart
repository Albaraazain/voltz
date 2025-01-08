class ReviewModel {
  final String id;
  final String userName;
  final int rating;
  final String comment;
  final DateTime timestamp;
  final List<String>? photos;
  final String? electricianReply;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
    this.photos,
    this.electricianReply,
  });

  // For now, we'll add a dummy data constructor for testing
  factory ReviewModel.dummy() {
    return ReviewModel(
      id: '1',
      userName: 'John Doe',
      rating: 4,
      comment: 'Great service! Very professional and punctual.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      photos: [],
      electricianReply: 'Thank you for your kind review!',
    );
  }
}
