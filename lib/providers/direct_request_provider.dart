import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/direct_request_model.dart';
import '../core/services/logger_service.dart';
import '../core/services/notification_service.dart';
import '../models/notification_model.dart';

class DirectRequestProvider extends ChangeNotifier {
  final SupabaseClient _client;
  bool _isLoading = false;
  List<DirectRequest> _requests = [];
  String? _error;

  DirectRequestProvider(this._client);

  // Getters
  bool get isLoading => _isLoading;
  List<DirectRequest> get requests => _requests;
  String? get error => _error;

  // Load requests with filters
  Future<void> loadRequests({
    String? electricianId,
    String? homeownerId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    bool ascending = false,
    int? limit,
    int? offset,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      dynamic query = _client.from('direct_requests').select();

      // Apply filters
      if (electricianId != null) {
        query = query.eq('electrician_id', electricianId);
      }

      if (homeownerId != null) {
        query = query.eq('homeowner_id', homeownerId);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      if (startDate != null) {
        query = query.gte(
            'preferred_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte(
            'preferred_date', endDate.toIso8601String().split('T')[0]);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('message', '%$searchQuery%');
      }

      // Apply ordering
      query = query.order('created_at', ascending: ascending);

      // Apply pagination
      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;
      _requests = response.map((json) => DirectRequest.fromJson(json)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Error loading filtered requests', e, stackTrace);
      _error = 'Failed to load requests';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter local requests
  List<DirectRequest> filterRequests({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    return _requests.where((request) {
      bool matches = true;

      if (status != null) {
        matches = matches && request.status == status;
      }

      if (startDate != null) {
        matches = matches && request.preferredDate.isAfter(startDate);
      }

      if (endDate != null) {
        matches = matches && request.preferredDate.isBefore(endDate);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        matches = matches &&
            (request.message
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false);
      }

      return matches;
    }).toList();
  }

  // Get requests for today
  List<DirectRequest> get todayRequests {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return filterRequests(startDate: today, endDate: today);
  }

  // Get requests for this week
  List<DirectRequest> get thisWeekRequests {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return filterRequests(
      startDate: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      endDate: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day),
    );
  }

  // Get requests for date range
  List<DirectRequest> getRequestsForDateRange(DateTime start, DateTime end) {
    return filterRequests(startDate: start, endDate: end);
  }

  // Get requests by status
  List<DirectRequest> getRequestsByStatus(String status) {
    return filterRequests(status: status);
  }

  // Search requests
  List<DirectRequest> searchRequests(String query) {
    return filterRequests(searchQuery: query);
  }

  // Load requests for an electrician
  Future<void> loadElectricianRequests(String electricianId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('direct_requests')
          .select()
          .eq('electrician_id', electricianId)
          .order('created_at', ascending: false);

      _requests = response.map((json) => DirectRequest.fromJson(json)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Error loading electrician requests', e, stackTrace);
      _error = 'Failed to load requests';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load requests for a homeowner
  Future<void> loadHomeownerRequests(String homeownerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('direct_requests')
          .select()
          .eq('homeowner_id', homeownerId)
          .order('created_at', ascending: false);

      _requests = response.map((json) => DirectRequest.fromJson(json)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Error loading homeowner requests', e, stackTrace);
      _error = 'Failed to load requests';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new direct request
  Future<DirectRequest> createRequest(DirectRequest request) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('direct_requests')
          .insert(request.toJson())
          .select()
          .single();

      final newRequest = DirectRequest.fromJson(response);
      _requests.insert(0, newRequest);

      // Create notification for electrician
      await _client.from('notifications').insert({
        'electrician_id': request.electricianId,
        'title': 'New Job Request',
        'message': 'You have received a new direct job request',
        'type': NotificationType.jobRequest.toString().split('.').last,
        'read': false,
      });

      // Show local notification
      await NotificationService.showNotification(
        title: 'New Job Request',
        body: 'You have received a new direct job request',
        payload: 'job_request_${newRequest.id}',
      );

      notifyListeners();
      return newRequest;
    } catch (e, stackTrace) {
      LoggerService.error('Error creating direct request', e, stackTrace);
      _error = 'Failed to create request';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update request status
  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('direct_requests')
          .update({'status': newStatus})
          .eq('id', requestId)
          .select()
          .single();

      final updatedRequest = DirectRequest.fromJson(response);
      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _requests[index] = updatedRequest;
      }

      // Create notification based on status
      String title, message;
      NotificationType type;

      switch (newStatus) {
        case DirectRequest.STATUS_ACCEPTED:
          title = 'Request Accepted';
          message = 'Your job request has been accepted';
          type = NotificationType.jobAccepted;
          break;
        case DirectRequest.STATUS_DECLINED:
          title = 'Request Declined';
          message = 'Your job request has been declined';
          type = NotificationType.jobDeclined;
          break;
        default:
          return;
      }

      // Create notification for homeowner
      await _client.from('notifications').insert({
        'electrician_id': updatedRequest.electricianId,
        'title': title,
        'message': message,
        'type': type.toString().split('.').last,
        'read': false,
      });

      // Show local notification
      await NotificationService.showNotification(
        title: title,
        body: message,
        payload: 'job_request_${updatedRequest.id}',
      );
    } catch (e, stackTrace) {
      LoggerService.error('Error updating request status', e, stackTrace);
      _error = 'Failed to update request status';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get pending requests
  List<DirectRequest> get pendingRequests {
    return _requests
        .where((request) => request.status == DirectRequest.STATUS_PENDING)
        .toList();
  }

  // Get accepted requests
  List<DirectRequest> get acceptedRequests {
    return _requests
        .where((request) => request.status == DirectRequest.STATUS_ACCEPTED)
        .toList();
  }

  // Get declined requests
  List<DirectRequest> get declinedRequests {
    return _requests
        .where((request) => request.status == DirectRequest.STATUS_DECLINED)
        .toList();
  }

  // Get request by ID
  DirectRequest? getRequestById(String requestId) {
    try {
      return _requests.firstWhere((request) => request.id == requestId);
    } catch (e) {
      return null;
    }
  }

  // Clear all data (useful when logging out)
  void clear() {
    _requests = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
