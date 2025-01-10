class Profile {
  final String id;
  final String email;
  final String userType;
  final String name;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  Profile({
    required this.id,
    required this.email,
    required this.userType,
    required this.name,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      email: map['email'],
      userType: map['user_type'],
      name: map['name'],
      createdAt: DateTime.parse(map['created_at']),
      lastLoginAt: map['last_login_at'] != null
          ? DateTime.parse(map['last_login_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'user_type': userType,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
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
