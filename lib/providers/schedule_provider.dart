import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/logger_service.dart';
import '../core/services/notification_service.dart';
import '../models/working_hours_model.dart';
import '../models/reschedule_request_model.dart';
import 'availability_provider.dart';

class ScheduleProvider extends ChangeNotifier {
  final SupabaseClient _client;
  final AvailabilityProvider _availabilityProvider;
  bool _isLoading = false;
  Map<String, List<ScheduleSlot>> _scheduleSlots = {};
  List<RescheduleRequest> _rescheduleRequests = [];
  String? _error;

  ScheduleProvider(this._client, this._availabilityProvider);

  bool get isLoading => _isLoading;
  Map<String, List<ScheduleSlot>> get scheduleSlots => _scheduleSlots;
  String? get error => _error;

  List<RescheduleRequest> get pendingRescheduleRequests => _rescheduleRequests
      .where((request) => request.status == RescheduleRequest.STATUS_PENDING)
      .toList();

  List<RescheduleRequest> get acceptedRescheduleRequests => _rescheduleRequests
      .where((request) => request.status == RescheduleRequest.STATUS_ACCEPTED)
      .toList();

  List<RescheduleRequest> get declinedRescheduleRequests => _rescheduleRequests
      .where((request) => request.status == RescheduleRequest.STATUS_DECLINED)
      .toList();

  // Load schedule slots for a specific date range
  Future<void> loadScheduleSlots(
      String electricianId, DateTime startDate, DateTime endDate) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('schedule_slots')
          .select()
          .eq('electrician_id', electricianId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('date');

      // Group slots by date
      _scheduleSlots = {};
      for (final slot in response) {
        final date = slot['date'] as String;
        if (!_scheduleSlots.containsKey(date)) {
          _scheduleSlots[date] = [];
        }
        _scheduleSlots[date]!.add(ScheduleSlot.fromJson(slot));
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error loading schedule slots', e, stackTrace);
      _error = 'Failed to load schedule slots';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new booking slot
  Future<void> createBookingSlot(ScheduleSlot slot) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if the slot conflicts with availability
      final availabilitySlots =
          _availabilityProvider.availabilitySlots[slot.date] ?? [];
      if (!_isTimeSlotAvailable(slot, availabilitySlots)) {
        throw Exception('Time slot is not available');
      }

      // Check for existing bookings
      if (await _hasBookingConflict(slot)) {
        throw Exception('Time slot conflicts with existing booking');
      }

      final response = await _client
          .from('schedule_slots')
          .insert(slot.toJson())
          .select()
          .single();

      final newSlot = ScheduleSlot.fromJson(response);
      if (!_scheduleSlots.containsKey(newSlot.date)) {
        _scheduleSlots[newSlot.date] = [];
      }
      _scheduleSlots[newSlot.date]!.add(newSlot);
    } catch (e, stackTrace) {
      LoggerService.error('Error creating booking slot', e, stackTrace);
      _error = 'Failed to create booking slot';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update a schedule slot
  Future<void> updateScheduleSlot(
      String slotId, Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('schedule_slots')
          .update(updates)
          .eq('id', slotId)
          .select()
          .single();

      final updatedSlot = ScheduleSlot.fromJson(response);
      final date = updatedSlot.date;

      final index =
          _scheduleSlots[date]?.indexWhere((slot) => slot.id == slotId) ?? -1;
      if (index != -1) {
        _scheduleSlots[date]![index] = updatedSlot;
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error updating schedule slot', e, stackTrace);
      _error = 'Failed to update schedule slot';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle reschedule request
  Future<void> createRescheduleRequest({
    required String jobId,
    required String requestedById,
    required String requestedByType,
    required DateTime originalDate,
    required String originalTime,
    required DateTime proposedDate,
    required String proposedTime,
    required String reason,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if the proposed time is available
      final proposedSlot = ScheduleSlot(
        id: '', // Will be generated by the database
        electricianId: '', // Will be set from the job
        date: proposedDate.toIso8601String().split('T')[0],
        startTime: proposedTime,
        endTime: _calculateEndTime(proposedTime),
        status: ScheduleSlot.STATUS_PENDING,
      );

      if (await _hasBookingConflict(proposedSlot)) {
        throw Exception('Proposed time conflicts with existing booking');
      }

      await _client.from('reschedule_requests').insert({
        'job_id': jobId,
        'requested_by_id': requestedById,
        'requested_by_type': requestedByType,
        'original_date': originalDate.toIso8601String().split('T')[0],
        'original_time': originalTime,
        'proposed_date': proposedDate.toIso8601String().split('T')[0],
        'proposed_time': proposedTime,
        'status': 'PENDING',
        'reason': reason,
      });
    } catch (e, stackTrace) {
      LoggerService.error('Error creating reschedule request', e, stackTrace);
      _error = 'Failed to create reschedule request';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle reschedule response
  Future<void> respondToRescheduleRequest(
      String requestId, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('reschedule_requests')
          .update({'status': status})
          .eq('id', requestId)
          .select()
          .single();

      if (status == 'ACCEPTED') {
        // Update the job's schedule
        final request = response;
        await _client.from('jobs').update({
          'date': request['proposed_date'],
          'time': request['proposed_time'],
        }).eq('id', request['job_id']);

        // Update schedule slots
        await _updateScheduleSlotsForReschedule(
          request['job_id'],
          request['original_date'],
          request['original_time'],
          request['proposed_date'],
          request['proposed_time'],
        );
      }
    } catch (e, stackTrace) {
      LoggerService.error(
          'Error responding to reschedule request', e, stackTrace);
      _error = 'Failed to respond to reschedule request';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to check if a time slot is available
  bool _isTimeSlotAvailable(
      ScheduleSlot slot, List<AvailabilitySlot> availabilitySlots) {
    for (final availabilitySlot in availabilitySlots) {
      if (_isTimeWithinSlot(
        slot.startTime,
        slot.endTime,
        availabilitySlot.startTime,
        availabilitySlot.endTime,
      )) {
        return true;
      }
    }
    return false;
  }

  // Helper method to check for booking conflicts
  Future<bool> _hasBookingConflict(ScheduleSlot newSlot) async {
    final existingSlots = await _client
        .from('schedule_slots')
        .select()
        .eq('electrician_id', newSlot.electricianId)
        .eq('date', newSlot.date)
        .neq('status', ScheduleSlot.STATUS_CANCELLED);

    for (final slot in existingSlots) {
      final existing = ScheduleSlot.fromJson(slot);
      if (_timesOverlap(
        newSlot.startTime,
        newSlot.endTime,
        existing.startTime,
        existing.endTime,
      )) {
        return true;
      }
    }
    return false;
  }

  // Helper method to check if a time is within a slot
  bool _isTimeWithinSlot(
      String start1, String end1, String start2, String end2) {
    final startTime1 = _parseTime(start1);
    final endTime1 = _parseTime(end1);
    final startTime2 = _parseTime(start2);
    final endTime2 = _parseTime(end2);

    return !startTime1.isBefore(startTime2) && !endTime1.isAfter(endTime2);
  }

  // Helper method to check if two time ranges overlap
  bool _timesOverlap(String start1, String end1, String start2, String end2) {
    final startTime1 = _parseTime(start1);
    final endTime1 = _parseTime(end1);
    final startTime2 = _parseTime(start2);
    final endTime2 = _parseTime(end2);

    return startTime1.isBefore(endTime2) && endTime1.isAfter(startTime2);
  }

  // Helper method to parse time string
  DateTime _parseTime(String time) {
    final parts = time.split(':');
    return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  // Helper method to calculate end time (default to 1 hour duration)
  String _calculateEndTime(String startTime) {
    final start = _parseTime(startTime);
    final end = start.add(const Duration(hours: 1));
    return '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  }

  // Helper method to update schedule slots for reschedule
  Future<void> _updateScheduleSlotsForReschedule(
    String jobId,
    String originalDate,
    String originalTime,
    String proposedDate,
    String proposedTime,
  ) async {
    // Cancel the original slot
    await _client
        .from('schedule_slots')
        .update({'status': ScheduleSlot.STATUS_CANCELLED})
        .eq('job_id', jobId)
        .eq('date', originalDate)
        .eq('start_time', originalTime);

    // Create a new slot
    await _client.from('schedule_slots').insert({
      'job_id': jobId,
      'date': proposedDate,
      'start_time': proposedTime,
      'end_time': _calculateEndTime(proposedTime),
      'status': ScheduleSlot.STATUS_BOOKED,
    });

    // Reload the affected dates
    final dates = [originalDate, proposedDate];
    for (final date in dates) {
      final slots = await _client
          .from('schedule_slots')
          .select()
          .eq('date', date)
          .order('start_time');

      _scheduleSlots[date] =
          slots.map((s) => ScheduleSlot.fromJson(s)).toList();
    }
  }

  // Clear all data (useful when logging out)
  void clear() {
    _scheduleSlots = {};
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadRescheduleRequests(String electricianId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('reschedule_requests')
          .select()
          .eq('electrician_id', electricianId)
          .order('created_at', ascending: false);

      _rescheduleRequests =
          response.map((json) => RescheduleRequest.fromJson(json)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Error loading reschedule requests', e, stackTrace);
      _error = 'Failed to load reschedule requests';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> proposeNewTime(
      String requestId, DateTime date, String time) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('reschedule_requests')
          .update({
            'proposed_date': date.toIso8601String().split('T')[0],
            'proposed_time': time,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId)
          .select()
          .single();

      final updatedRequest = RescheduleRequest.fromJson(response);
      final index = _rescheduleRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _rescheduleRequests[index] = updatedRequest;
      }

      // Create notification for the homeowner
      await _client.from('notifications').insert({
        'homeowner_id': updatedRequest.requestedById,
        'title': 'New Time Proposed',
        'message': 'The electrician has proposed a new time for your job',
        'type': 'RESCHEDULE_PROPOSED',
        'read': false,
      });

      // Show local notification
      await NotificationService.showNotification(
        title: 'New Time Proposed',
        body: 'The electrician has proposed a new time for your job',
        payload: 'reschedule_request_${updatedRequest.id}',
      );
    } catch (e, stackTrace) {
      LoggerService.error('Error proposing new time', e, stackTrace);
      _error = 'Failed to propose new time';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class ScheduleSlot {
  static const String STATUS_AVAILABLE = 'AVAILABLE';
  static const String STATUS_BOOKED = 'BOOKED';
  static const String STATUS_BLOCKED = 'BLOCKED';
  static const String STATUS_CANCELLED = 'CANCELLED';
  static const String STATUS_PENDING = 'PENDING';

  final String id;
  final String electricianId;
  final String date;
  final String startTime;
  final String endTime;
  final String status;

  ScheduleSlot({
    required this.id,
    required this.electricianId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory ScheduleSlot.fromJson(Map<String, dynamic> json) {
    return ScheduleSlot(
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
