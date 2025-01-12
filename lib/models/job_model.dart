import 'homeowner_model.dart';
import 'electrician_model.dart';

class Job {
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
}
