import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/api_response.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

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

    _notifications = ApiResponse.loading();
    notifyListeners();

    _notifications = await _repository.getUserNotifications(
      _currentUserId!,
      limit: limit,
      offset: offset,
    );
    notifyListeners();

    // Update unread count
    await refreshUnreadCount();
  }

  /// Load unread notifications
  Future<void> loadUnreadNotifications() async {
    if (_currentUserId == null) return;

    _notifications = ApiResponse.loading();
    notifyListeners();

    _notifications = await _repository.getUnreadNotifications(_currentUserId!);
    notifyListeners();

    // Update unread count
    await refreshUnreadCount();
  }

  /// Refresh unread notification count
  Future<void> refreshUnreadCount() async {
    if (_currentUserId == null) return;

    _unreadCount = await _repository.getUnreadCount(_currentUserId!);
    notifyListeners();
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final response = await _repository.markAsRead(notificationId);
    if (response.hasData) {
      // Update the notification in the current list if it exists
      if (_notifications.hasData) {
        final index =
            _notifications.data!.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final updatedNotifications =
              List<NotificationModel>.from(_notifications.data!);
          updatedNotifications[index] = response.data!;
          _notifications = ApiResponse.success(updatedNotifications);
          notifyListeners();
        }
      }
      // Refresh unread count
      await refreshUnreadCount();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    final response = await _repository.markAllAsRead(_currentUserId!);
    if (response.hasData) {
      // Update all notifications in the current list
      if (_notifications.hasData) {
        final updatedNotifications = _notifications.data!.map((notification) {
          return notification.copyWith(isRead: true);
        }).toList();
        _notifications = ApiResponse.success(updatedNotifications);
        notifyListeners();
      }
      // Reset unread count
      _unreadCount = ApiResponse.success(0);
      notifyListeners();
    }
  }

  /// Get notifications by type
  Future<ApiResponse<List<NotificationModel>>> getNotificationsByType(
    NotificationType type,
  ) async {
    if (_currentUserId == null) {
      return ApiResponse.error('User not authenticated');
    }
    return _repository.getNotificationsByType(_currentUserId!, type);
  }

  /// Get notifications related to a specific entity
  Future<ApiResponse<List<NotificationModel>>> getRelatedNotifications(
    String relatedId,
  ) async {
    if (_currentUserId == null) {
      return ApiResponse.error('User not authenticated');
    }
    return _repository.getRelatedNotifications(_currentUserId!, relatedId);
  }

  /// Start listening to new notifications
  void startListeningToNotifications() {
    if (_currentUserId == null) return;

    _notificationSubscription?.cancel();
    _notificationSubscription =
        _repository.streamUserNotifications(_currentUserId!).listen((response) {
      _notifications = response;
      notifyListeners();
      // Update unread count when new notifications arrive
      refreshUnreadCount();
    });
  }

  /// Stop listening to notifications
  void stopListeningToNotifications() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
  }

  /// Delete old notifications
  Future<void> deleteOldNotifications({Duration? age}) async {
    if (_currentUserId == null) return;

    final response = await _repository.deleteOldNotifications(
      _currentUserId!,
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
