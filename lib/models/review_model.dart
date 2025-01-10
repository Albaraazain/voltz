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

  // For testing purposes - keeping as reference implementation
  factory ReviewModel.dummy() {
    // TODO: Replace dummy data with real review data from backend
    // TODO: Add proper user information fetching
    // TODO: Implement proper review ID generation
    // TODO: Add proper timestamp handling with user's timezone
    // TODO: Implement photo upload and storage functionality
    return ReviewModel(
      id: '1', // Reference ID format
      userName: 'John Doe', // Reference user format
      rating: 4, // Reference rating format
      comment:
          'Great service! Very professional and punctual.', // Reference comment format
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      photos: [], // Reference photos format
      electricianReply:
          'Thank you for your kind review!', // Reference reply format
    );
  }

  // TODO: Implement review verification system
  // TODO: Add review moderation system
  // TODO: Implement review response time tracking
  // TODO: Add review analytics and reporting
  // TODO: Implement review highlights and featured reviews
  // TODO: Add review categories (workmanship, punctuality, etc.)
  // TODO: Implement review sentiment analysis
  // TODO: Add review helpfulness voting
  // TODO: Implement review search and filtering
  // TODO: Add review guidelines and policy enforcement
}
