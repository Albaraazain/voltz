class DaySchedule {
  final String? start;
  final String? end;

  const DaySchedule({
    this.start,
    this.end,
  });

  factory DaySchedule.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DaySchedule();
    return DaySchedule(
      start: json['start'] as String?,
      end: json['end'] as String?,
    );
  }

  Map<String, dynamic>? toJson() {
    if (start == null && end == null) return null;
    return {
      'start': start,
      'end': end,
    };
  }

  DaySchedule copyWith({
    String? start,
    String? end,
  }) {
    return DaySchedule(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}

class WorkingHours {
  final DaySchedule? monday;
  final DaySchedule? tuesday;
  final DaySchedule? wednesday;
  final DaySchedule? thursday;
  final DaySchedule? friday;
  final DaySchedule? saturday;
  final DaySchedule? sunday;

  const WorkingHours({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  factory WorkingHours.defaults() => const WorkingHours(
        monday: DaySchedule(start: '09:00', end: '17:00'),
        tuesday: DaySchedule(start: '09:00', end: '17:00'),
        wednesday: DaySchedule(start: '09:00', end: '17:00'),
        thursday: DaySchedule(start: '09:00', end: '17:00'),
        friday: DaySchedule(start: '09:00', end: '17:00'),
        saturday: null,
        sunday: null,
      );

  factory WorkingHours.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WorkingHours();

    return WorkingHours(
      monday: DaySchedule.fromJson(json['monday'] as Map<String, dynamic>?),
      tuesday: DaySchedule.fromJson(json['tuesday'] as Map<String, dynamic>?),
      wednesday:
          DaySchedule.fromJson(json['wednesday'] as Map<String, dynamic>?),
      thursday: DaySchedule.fromJson(json['thursday'] as Map<String, dynamic>?),
      friday: DaySchedule.fromJson(json['friday'] as Map<String, dynamic>?),
      saturday: DaySchedule.fromJson(json['saturday'] as Map<String, dynamic>?),
      sunday: DaySchedule.fromJson(json['sunday'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monday': monday?.toJson(),
      'tuesday': tuesday?.toJson(),
      'wednesday': wednesday?.toJson(),
      'thursday': thursday?.toJson(),
      'friday': friday?.toJson(),
      'saturday': saturday?.toJson(),
      'sunday': sunday?.toJson(),
    };
  }

  WorkingHours copyWith({
    DaySchedule? monday,
    DaySchedule? tuesday,
    DaySchedule? wednesday,
    DaySchedule? thursday,
    DaySchedule? friday,
    DaySchedule? saturday,
    DaySchedule? sunday,
  }) {
    return WorkingHours(
      monday: monday ?? this.monday,
      tuesday: tuesday ?? this.tuesday,
      wednesday: wednesday ?? this.wednesday,
      thursday: thursday ?? this.thursday,
      friday: friday ?? this.friday,
      saturday: saturday ?? this.saturday,
      sunday: sunday ?? this.sunday,
    );
  }
}
