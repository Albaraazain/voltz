class Profile {
  final String id;
  final String email;
  final String userType;
  final String name;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const Profile({
    required this.id,
    required this.email,
    required this.userType,
    required this.name,
    required this.createdAt,
    this.lastLoginAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_type': userType,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      userType: json['user_type'] ?? '',
      name: json['name'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
    );
  }

  Profile copyWith({
    String? id,
    String? email,
    String? userType,
    String? name,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
