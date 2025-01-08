class Review {
  final String id;
  final String homeownerName;
  final String? homeownerPhotoUrl;
  final int rating;
  final String? comment;
  final String date;

  Review({
    required this.id,
    required this.homeownerName,
    this.homeownerPhotoUrl,
    required this.rating,
    this.comment,
    required this.date,
  });

  // For now, we'll add a dummy data constructor for testing
  factory Review.dummy() {
    return Review(
      id: '1',
      homeownerName: 'John Doe',
      rating: 4,
      date: '2024-02-20',
      comment: 'Great service! Very professional and punctual.',
    );
  }
}
