import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/api_response.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import '../core/services/logger_service.dart';

/// Provider for managing notifications in the application.
///
/// This provider interacts with the notifications table which has the following security policies:
///
/// 1. Row Level Security (RLS) is enabled
/// 2. Users can only view their own notifications (profile_id = auth.uid())
/// 3. Users can only update their own notifications (profile_id = auth.uid())
/// 4. System can create notifications for any user (unrestricted INSERT)
///
/// The notifications table uses a unified schema that works for both homeowners and electricians:
/// - Each notification is tied to a user's profile_id
/// - Notifications can be of different types (job_request, job_update, payment, review, system)
/// - The read status is tracked per notification
/// - Related entities (jobs, reviews, etc.) can be referenced via related_id
class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;
  final String? _currentUserId;

  ApiResponse<List<NotificationModel>> _notifications = ApiResponse.initial();
  ApiResponse<int> _unreadCount = ApiResponse.initial();
  StreamSubscription<ApiResponse<List<NotificationModel>>>?
      _notificationSubscription;

  NotificationProvider(SupabaseClient supabase, [this._currentUserId])
      : _repository = NotificationRepository(supabase);

  ApiResponse<List<NotificationModel>> get notifications => _notifications;
  ApiResponse<int> get unreadCount => _unreadCount;

  /// Load notifications for the current user
  Future<void> loadNotifications({int? limit, int? offset}) async {
    if (_currentUserId == null) return;

    LoggerService.debug('Loading notifications for user: $_currentUserId');
    _notifications = ApiResponse.loading();
    notifyListeners();

    try {
      _notifications = await _repository.getUserNotifications(
        _currentUserId,
        limit: limit,
        offset: offset,
      );
      LoggerService.debug(
          'Loaded ${_notifications.data?.length ?? 0} notifications');
      notifyListeners();

      // Update unread count
      await refreshUnreadCount();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load notifications', e, stackTrace);
      _notifications = ApiResponse.error(e.toString());
      notifyListeners();
    }
  }

  /// Load unread notifications
  Future<void> loadUnreadNotifications() async {
    if (_currentUserId == null) return;

    LoggerService.debug(
        'Loading unread notifications for user: $_currentUserId');
    _notifications = ApiResponse.loading();
    notifyListeners();

    try {
      _notifications = await _repository.getUnreadNotifications(_currentUserId);
      LoggerService.debug(
          'Loaded ${_notifications.data?.length ?? 0} unread notifications');
      notifyListeners();

      // Update unread count
      await refreshUnreadCount();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load unread notifications', e, stackTrace);
      _notifications = ApiResponse.error(e.toString());
      notifyListeners();
    }
  }

  /// Refresh unread notification count
  Future<void> refreshUnreadCount() async {
    if (_currentUserId == null) return;

    LoggerService.debug('Refreshing unread count for user: $_currentUserId');
    try {
      _unreadCount = await _repository.getUnreadCount(_currentUserId);
      LoggerService.debug('Unread count: ${_unreadCount.data ?? 0}');
      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to refresh unread count', e, stackTrace);
      _unreadCount = ApiResponse.error(e.toString());
      notifyListeners();
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    LoggerService.debug('Marking notification as read: $notificationId');
    try {
      final response = await _repository.markAsRead(notificationId);
      if (response.hasData && _notifications.hasData) {
        final index =
            _notifications.data!.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final updatedNotifications =
              List<NotificationModel>.from(_notifications.data!);
          updatedNotifications[index] = response.data!;
          _notifications = ApiResponse.success(updatedNotifications);
          notifyListeners();
        }
        // Refresh unread count
        await refreshUnreadCount();
        LoggerService.debug('Successfully marked notification as read');
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to mark notification as read', e, stackTrace);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    LoggerService.debug(
        'Marking all notifications as read for user: $_currentUserId');
    try {
      final response = await _repository.markAllAsRead(_currentUserId);
      if (response.hasData && _notifications.hasData) {
        final updatedNotifications = _notifications.data!.map((notification) {
          return notification.copyWith(read: true);
        }).toList();
        _notifications = ApiResponse.success(updatedNotifications);
        notifyListeners();

        // Reset unread count
        _unreadCount = ApiResponse.success(0);
        notifyListeners();
        LoggerService.debug('Successfully marked all notifications as read');
      }
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to mark all notifications as read', e, stackTrace);
    }
  }

  /// Get notifications by type
  Future<ApiResponse<List<NotificationModel>>> getNotificationsByType(
    NotificationType type,
  ) async {
    if (_currentUserId == null) {
      return ApiResponse.error('User not authenticated');
    }
    return _repository.getNotificationsByType(_currentUserId, type);
  }

  /// Get notifications related to a specific entity
  Future<ApiResponse<List<NotificationModel>>> getRelatedNotifications(
    String relatedId,
  ) async {
    if (_currentUserId == null) {
      return ApiResponse.error('User not authenticated');
    }
    return _repository.getRelatedNotifications(_currentUserId, relatedId);
  }

  /// Start listening to new notifications
  void startListeningToNotifications() {
    if (_currentUserId == null) return;

    LoggerService.debug(
        'Starting notification listener for user: $_currentUserId');
    _notificationSubscription?.cancel();
    _notificationSubscription =
        _repository.streamUserNotifications(_currentUserId).listen(
      (response) {
        _notifications = response;
        notifyListeners();
        // Update unread count when new notifications arrive
        refreshUnreadCount();
        LoggerService.debug('Received notification update');
      },
      onError: (e, stackTrace) {
        LoggerService.error('Error in notification stream', e, stackTrace);
      },
    );
  }

  /// Stop listening to notifications
  void stopListeningToNotifications() {
    LoggerService.debug('Stopping notification listener');
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
  }

  /// Delete old notifications
  Future<void> deleteOldNotifications({Duration? age}) async {
    if (_currentUserId == null) return;

    final response = await _repository.deleteOldNotifications(
      _currentUserId,
      age: age ?? const Duration(days: 30),
    );
    if (response.hasData) {
      // Refresh notifications list
      await loadNotifications();
    }
  }

  @override
  void dispose() {
    stopListeningToNotifications();
    super.dispose();
  }
}
