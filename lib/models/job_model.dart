import 'homeowner_model.dart';
import 'electrician_model.dart';

class Job {
  // TODO: Add payment status tracking (Requires: Payment system implementation)
  // TODO: Add job location and distance calculation (Requires: Location services)
  // TODO: Add job completion verification fields (Requires: Job verification system)
  // TODO: Add job timeline tracking (Requires: Progress tracking system)
  // TODO: Add job materials and cost breakdown (Requires: Inventory system)
  // TODO: Add job ratings and review fields (Requires: Review system)
  // TODO: Add emergency status flag (Requires: Emergency handling system)
  // TODO: Add job scheduling preferences (Requires: Scheduling system)

  static const String STATUS_ACTIVE = 'active';
  static const String STATUS_COMPLETED = 'completed';
  static const String STATUS_CANCELLED = 'cancelled';
  static const String STATUS_IN_PROGRESS = 'in_progress';
  static const String STATUS_PENDING = 'pending';

  // TODO: Add payment status constants (Requires: Payment system)
  // TODO: Add verification status constants (Requires: Verification system)
  // TODO: Add emergency status constants (Requires: Emergency system)

  static const double MIN_PRICE = 20.0;
  static const double MAX_PRICE = 10000.0;

  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime date;
  final Electrician? electrician;
  final Homeowner homeowner;
  final double price;
  final DateTime createdAt;

  const Job({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.date,
    this.electrician,
    required this.homeowner,
    required this.price,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'date': date.toIso8601String(),
      'electrician': electrician?.toJson(),
      'homeowner': homeowner.toJson(),
      'price': price,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      date: DateTime.parse(json['date']),
      electrician: json['electrician'] != null
          ? Electrician.fromJson(json['electrician'])
          : null,
      homeowner: Homeowner.fromJson(json['homeowner']),
      price: json['price'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Job copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    DateTime? date,
    Electrician? electrician,
    Homeowner? homeowner,
    double? price,
    DateTime? createdAt,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      date: date ?? this.date,
      electrician: electrician ?? this.electrician,
      homeowner: homeowner ?? this.homeowner,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static bool isValidStatus(String status) {
    return [
      STATUS_ACTIVE,
      STATUS_COMPLETED,
      STATUS_CANCELLED,
      STATUS_IN_PROGRESS,
      STATUS_PENDING
    ].contains(status);
  }

  static bool isValidPrice(double price) {
    return price >= MIN_PRICE && price <= MAX_PRICE;
  }
}
