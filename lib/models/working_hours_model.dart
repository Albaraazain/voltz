class WorkingHours {
  final String id;
  final String electricianId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isWorkingDay;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkingHours({
    required this.id,
    required this.electricianId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isWorkingDay,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    String formatTimeString(dynamic time) {
      if (time == null) return '00:00';
      final timeStr = time.toString();
      // If the time includes seconds (HH:MM:SS), remove them
      return timeStr.split('.')[0].substring(0, 5);
    }

    return WorkingHours(
      id: json['id'] ?? '${json['electrician_id']}_${json['day_of_week']}',
      electricianId: json['electrician_id'] ?? '',
      dayOfWeek: json['day_of_week'] ?? 0,
      startTime: formatTimeString(json['start_time']),
      endTime: formatTimeString(json['end_time']),
      isWorkingDay: json['is_working_day'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'electrician_id': electricianId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_working_day': isWorkingDay,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WorkingHours copyWith({
    String? id,
    String? electricianId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isWorkingDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkingHours(
      id: id ?? this.id,
      electricianId: electricianId ?? this.electricianId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isWorkingDay: isWorkingDay ?? this.isWorkingDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  String get dayName => WorkingHours.getDayName(dayOfWeek);

  static String getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 0:
        return 'Sunday';
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      default:
        throw ArgumentError('Invalid day of week: $dayOfWeek');
    }
  }

  static int getDayOfWeek(String dayName) {
    switch (dayName.toLowerCase()) {
      case 'sunday':
        return 0;
      case 'monday':
        return 1;
      case 'tuesday':
        return 2;
      case 'wednesday':
        return 3;
      case 'thursday':
        return 4;
      case 'friday':
        return 5;
      case 'saturday':
        return 6;
      default:
        throw ArgumentError('Invalid day name: $dayName');
    }
  }

  static List<WorkingHours> defaults({required String electricianId}) {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final isWeekday = index > 0 && index < 6; // Monday-Friday
      return WorkingHours(
        id: '', // Will be set by the database
        electricianId: electricianId,
        dayOfWeek: index,
        startTime: '09:00',
        endTime: '17:00',
        isWorkingDay: isWeekday,
        createdAt: now,
        updatedAt: now,
      );
    });
  }
}
