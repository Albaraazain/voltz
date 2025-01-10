class JobModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime date;
  final String homeownerId;
  final double price;
  final DateTime createdAt;
  final DateTime? updatedAt;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.date,
    required this.homeownerId,
    required this.price,
    required this.createdAt,
    this.updatedAt,
  });

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      date: DateTime.parse(map['date'] as String),
      homeownerId: map['homeowner_id'] as String,
      price: (map['price'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'date': date.toIso8601String(),
      'homeowner_id': homeownerId,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  JobModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    DateTime? date,
    String? homeownerId,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      date: date ?? this.date,
      homeownerId: homeownerId ?? this.homeownerId,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
