import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/api_response.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _client;

  NotificationRepository(this._client);

  Future<ApiResponse<List<NotificationModel>>> getUserNotifications(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('profile_id', userId)
          .order('created_at', ascending: false)
          .limit(limit ?? 20)
          .range(offset ?? 0, (offset ?? 0) + (limit ?? 20) - 1);

      final notifications = (response as List)
          .map((data) => NotificationModel.fromMap(data))
          .toList();

      return ApiResponse.success(notifications);
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }

  Future<ApiResponse<List<NotificationModel>>> getUnreadNotifications(
    String userId,
  ) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('profile_id', userId)
          .eq('read', false)
          .order('created_at', ascending: false);

      final notifications = (response as List)
          .map((data) => NotificationModel.fromMap(data))
          .toList();

      return ApiResponse.success(notifications);
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }

  Future<ApiResponse<int>> getUnreadCount(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select('id')
          .eq('profile_id', userId)
          .eq('read', false);

      return ApiResponse.success((response as List).length);
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }

  Future<ApiResponse<NotificationModel>> markAsRead(
      String notificationId) async {
    try {
      final response = await _client
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId)
          .select()
          .single();

      return ApiResponse.success(NotificationModel.fromMap(response));
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }

  Future<ApiResponse<List<NotificationModel>>> markAllAsRead(
      String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .update({'read': true})
          .eq('profile_id', userId)
          .select();

      final notifications = (response as List)
          .map((data) => NotificationModel.fromMap(data))
          .toList();

      return ApiResponse.success(notifications);
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }

  Future<ApiResponse<List<NotificationModel>>> getNotificationsByType(
    String userId,
    NotificationType type,
  ) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('profile_id', userId)
          .eq('type', type.toString().split('.').last)
          .order('created_at', ascending: false);

      final notifications = (response as List)
          .map((data) => NotificationModel.fromMap(data))
          .toList();

      return ApiResponse.success(notifications);
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }

  Future<ApiResponse<List<NotificationModel>>> getRelatedNotifications(
    String userId,
    String relatedId,
  ) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('profile_id', userId)
          .eq('related_id', relatedId)
          .order('created_at', ascending: false);

      final notifications = (response as List)
          .map((data) => NotificationModel.fromMap(data))
          .toList();

      return ApiResponse.success(notifications);
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }

  Stream<ApiResponse<List<NotificationModel>>> streamUserNotifications(
    String userId,
  ) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('profile_id', userId)
        .order('created_at')
        .map((data) {
          try {
            final notifications =
                data.map((row) => NotificationModel.fromMap(row));
            return ApiResponse.success(notifications.toList());
          } catch (error, stackTrace) {
            return ApiResponse.error(error, stackTrace);
          }
        });
  }

  Future<ApiResponse<void>> deleteOldNotifications(
    String userId, {
    Duration age = const Duration(days: 30),
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(age);
      await _client
          .from('notifications')
          .delete()
          .eq('profile_id', userId)
          .lt('created_at', cutoffDate.toIso8601String());

      return ApiResponse.success(null);
    } catch (error, stackTrace) {
      return ApiResponse.error(error, stackTrace);
    }
  }
}
