class Job {
  final String id;
  final String homeownerId;
  final String electricianId;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;

  Job({
    required this.id,
    required this.homeownerId,
    required this.electricianId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'] as String,
      homeownerId: map['homeowner_id'] as String,
      electricianId: map['electrician_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'homeowner_id': homeownerId,
      'electrician_id': electricianId,
      'title': title,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Job(id: $id, homeownerId: $homeownerId, electricianId: $electricianId, title: $title, description: $description, status: $status, createdAt: $createdAt)';
  }
}
