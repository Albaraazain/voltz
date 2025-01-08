class ReviewModel {
  final String id;
  final String userId;
  final String electricianId;
  final String jobId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime timestamp;
  final List<String>? photos;
  final String? electricianReply;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.electricianId,
    required this.jobId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
    this.photos,
    this.electricianReply,
  });
}