class CalendarSync {
  final String id;
  final String userId;
  final String provider;
  final String calendarId;
  final String accessToken;
  final String? refreshToken;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CalendarSync({
    required this.id,
    required this.userId,
    required this.provider,
    required this.calendarId,
    required this.accessToken,
    this.refreshToken,
    this.lastSyncedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CalendarSync.fromJson(Map<String, dynamic> json) {
    return CalendarSync(
      id: json['id'],
      userId: json['user_id'],
      provider: json['provider'],
      calendarId: json['calendar_id'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'provider': provider,
      'calendar_id': calendarId,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CalendarSync copyWith({
    String? id,
    String? userId,
    String? provider,
    String? calendarId,
    String? accessToken,
    String? refreshToken,
    DateTime? lastSyncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarSync(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      provider: provider ?? this.provider,
      calendarId: calendarId ?? this.calendarId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
