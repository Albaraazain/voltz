class AvailabilitySlot {
  static const String STATUS_AVAILABLE = 'AVAILABLE';
  static const String STATUS_BOOKED = 'BOOKED';
  static const String STATUS_BLOCKED = 'BLOCKED';

  final String id;
  final String electricianId;
  final String date;
  final String startTime;
  final String endTime;
  final String status;

  const AvailabilitySlot({
    required this.id,
    required this.electricianId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      id: json['id'],
      electricianId: json['electrician_id'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'electrician_id': electricianId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
    };
  }
}
