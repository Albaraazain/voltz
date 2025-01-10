class Electrician {
  final String id;
  final String name;
  final String email;
  final double rating;
  final int jobsCompleted;
  final double hourlyRate;
  final bool isAvailable;
  final String? profileImage;
  final DateTime createdAt;

  Electrician({
    required this.id,
    required this.name,
    required this.email,
    required this.rating,
    required this.jobsCompleted,
    required this.hourlyRate,
    required this.isAvailable,
    this.profileImage,
    required this.createdAt,
  });

  factory Electrician.fromMap(Map<String, dynamic> map) {
    return Electrician(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      rating: (map['rating'] as num).toDouble(),
      jobsCompleted: map['jobs_completed'] as int,
      hourlyRate: (map['hourly_rate'] as num).toDouble(),
      isAvailable: map['is_available'] as bool,
      profileImage: map['profile_image'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'rating': rating,
      'jobs_completed': jobsCompleted,
      'hourly_rate': hourlyRate,
      'is_available': isAvailable,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Electrician(id: $id, name: $name, email: $email, rating: $rating, jobsCompleted: $jobsCompleted, hourlyRate: $hourlyRate, isAvailable: $isAvailable, profileImage: $profileImage, createdAt: $createdAt)';
  }
}
