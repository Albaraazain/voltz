class Job {
  final String id;
  final String title;
  final String? description;
  final String status;
  final DateTime date;
  final String? electricianId;
  final String homeownerId;
  final double price;

  Job({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.date,
    this.electricianId,
    required this.homeownerId,
    required this.price,
  });

  // Convert a Map (from database) to a Job object
  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      date: DateTime.parse(map['date']),
      electricianId: map['electrician_id'],
      homeownerId: map['homeowner_id'],
      price: map['price'].toDouble(),
    );
  }

  // Convert a Job object to a Map (for database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'date': date.toIso8601String(),
      'electrician_id': electricianId,
      'homeowner_id': homeownerId,
      'price': price,
    };
  }
}
