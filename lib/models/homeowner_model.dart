class Homeowner {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final String? phone;
  final String? address;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  Homeowner({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.phone,
    this.address,
    required this.createdAt,
    this.lastLoginAt,
  });

  // Convert a Map (from database) to a Homeowner object
  factory Homeowner.fromMap(Map<String, dynamic> map) {
    return Homeowner(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      passwordHash: map['passwordHash'],
      phone: map['phone'],
      address: map['address'],
      createdAt: DateTime.parse(map['createdAt']),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'])
          : null,
    );
  }

  // Convert a Homeowner object to a Map (for database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'phone': phone,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  // Create a copy of the Homeowner with updated fields
  Homeowner copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    String? phone,
    String? address,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return Homeowner(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
