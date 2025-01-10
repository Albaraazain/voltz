import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/repositories/base_repository.dart';
import '../core/utils/api_response.dart';
import '../models/notification_model.dart';

class NotificationRepository extends BaseRepository<NotificationModel> {
  NotificationRepository(SupabaseClient supabase)
      : super(supabase, 'notifications');

  @override
  NotificationModel fromJson(Map<String, dynamic> json) =>
      NotificationModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(NotificationModel entity) => entity.toJson();

  /// Get unread notifications for a user
  Future<ApiResponse<List<NotificationModel>>> getUnreadNotifications(
    String profileId,
  ) async {
    return list(
      filters: {
        'profile_id': profileId,
        'is_read': false,
      },
      orderBy: 'created_at',
      ascending: false,
    );
  }

  /// Get all notifications for a user with pagination
  Future<ApiResponse<List<NotificationModel>>> getUserNotifications(
    String profileId, {
    int? limit,
    int? offset,
  }) async {
    return list(
      filters: {'profile_id': profileId},
      orderBy: 'created_at',
      ascending: false,
      limit: limit,
      offset: offset,
    );
  }

  /// Mark a notification as read
  Future<ApiResponse<NotificationModel>> markAsRead(
      String notificationId) async {
    return customMutation((client) async {
      final response = await client
          .from(table)
          .update({'is_read': true})
          .eq('id', notificationId)
          .select()
          .single();
      return response;
    });
  }

  /// Mark all notifications as read for a user
  Future<ApiResponse<bool>> markAllAsRead(String profileId) async {
    try {
      await supabase
          .from(table)
          .update({'is_read': true})
          .eq('profile_id', profileId)
          .eq('is_read', false);
      return ApiResponse.success(true);
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }

  /// Get notifications by type
  Future<ApiResponse<List<NotificationModel>>> getNotificationsByType(
    String profileId,
    NotificationType type,
  ) async {
    return list(
      filters: {
        'profile_id': profileId,
        'type': type.toString().split('.').last,
      },
      orderBy: 'created_at',
      ascending: false,
    );
  }

  /// Get notifications related to a specific entity
  Future<ApiResponse<List<NotificationModel>>> getRelatedNotifications(
    String profileId,
    String relatedId,
  ) async {
    return list(
      filters: {
        'profile_id': profileId,
        'related_id': relatedId,
      },
      orderBy: 'created_at',
      ascending: false,
    );
  }

  /// Stream new notifications for a user
  Stream<ApiResponse<List<NotificationModel>>> streamUserNotifications(
    String profileId,
  ) {
    return stream(
      filters: {'profile_id': profileId},
      orderBy: 'created_at',
      ascending: false,
    );
  }

  /// Get unread notification count for a user
  Future<ApiResponse<int>> getUnreadCount(String profileId) async {
    try {
      final response = await supabase
          .from(table)
          .select()
          .eq('profile_id', profileId)
          .eq('is_read', false);

      return ApiResponse.success((response as List).length);
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }

  /// Delete old notifications for a user
  Future<ApiResponse<bool>> deleteOldNotifications(
    String profileId, {
    Duration age = const Duration(days: 30),
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(age);
      await supabase
          .from(table)
          .delete()
          .eq('profile_id', profileId)
          .lt('created_at', cutoffDate.toIso8601String());

      return ApiResponse.success(true);
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }
}
