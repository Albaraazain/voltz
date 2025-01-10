class Electrician {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final double rating;
  final int jobsCompleted;
  final double hourlyRate;
  final String? profileImage;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  Electrician({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.rating = 0.0,
    this.jobsCompleted = 0,
    this.hourlyRate = 0.0,
    this.profileImage,
    this.isAvailable = true,
    required this.createdAt,
    this.lastLoginAt,
  });

  // Convert a Map (from database) to an Electrician object
  factory Electrician.fromMap(Map<String, dynamic> map) {
    return Electrician(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      passwordHash: map['password_hash'],
      rating: map['rating']?.toDouble() ?? 0.0,
      jobsCompleted: map['jobs_completed'] ?? 0,
      hourlyRate: map['hourly_rate']?.toDouble() ?? 0.0,
      profileImage: map['profile_image'],
      isAvailable: map['is_available'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
      lastLoginAt: map['last_login_at'] != null
          ? DateTime.parse(map['last_login_at'])
          : null,
    );
  }

  // Convert an Electrician object to a Map (for database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'rating': rating,
      'jobs_completed': jobsCompleted,
      'hourly_rate': hourlyRate,
      'profile_image': profileImage,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  // Create a copy of the Electrician with updated fields
  Electrician copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    double? rating,
    int? jobsCompleted,
    double? hourlyRate,
    String? profileImage,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return Electrician(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      rating: rating ?? this.rating,
      jobsCompleted: jobsCompleted ?? this.jobsCompleted,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      profileImage: profileImage ?? this.profileImage,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
