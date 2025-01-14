import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/logger_service.dart';
import '../models/working_hours_model.dart';

class AvailabilityProvider extends ChangeNotifier {
  final SupabaseClient _client;
  bool _isLoading = false;
  Map<String, List<AvailabilitySlot>> _availabilitySlots = {};
  String? _error;

  AvailabilityProvider(this._client);

  bool get isLoading => _isLoading;
  Map<String, List<AvailabilitySlot>> get availabilitySlots =>
      _availabilitySlots;
  String? get error => _error;

  // Load availability slots for a specific date range
  Future<void> loadAvailabilitySlots(
      String electricianId, DateTime startDate, DateTime endDate) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('electrician_availability')
          .select()
          .eq('electrician_id', electricianId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('date');

      // Group slots by date
      _availabilitySlots = {};
      for (final slot in response) {
        final date = slot['date'] as String;
        if (!_availabilitySlots.containsKey(date)) {
          _availabilitySlots[date] = [];
        }
        _availabilitySlots[date]!.add(AvailabilitySlot.fromJson(slot));
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error loading availability slots', e, stackTrace);
      _error = 'Failed to load availability slots';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new availability slot
  Future<void> createAvailabilitySlot(AvailabilitySlot slot) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check for conflicts
      if (await _hasConflict(slot)) {
        throw Exception('Time slot conflicts with existing availability');
      }

      final response = await _client
          .from('electrician_availability')
          .insert(slot.toJson())
          .select()
          .single();

      final newSlot = AvailabilitySlot.fromJson(response);
      if (!_availabilitySlots.containsKey(newSlot.date)) {
        _availabilitySlots[newSlot.date] = [];
      }
      _availabilitySlots[newSlot.date]!.add(newSlot);
    } catch (e, stackTrace) {
      LoggerService.error('Error creating availability slot', e, stackTrace);
      _error = 'Failed to create availability slot';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create recurring availability slots
  Future<void> createRecurringSlots({
    required String electricianId,
    required WorkingHours workingHours,
    required DateTime startDate,
    required DateTime endDate,
    required int bufferMinutes,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final slots = <Map<String, dynamic>>[];
      var currentDate = startDate;

      while (!currentDate.isAfter(endDate)) {
        final dayName = _getDayName(currentDate.weekday).toLowerCase();
        final schedule = workingHours.schedule[dayName];

        if (schedule != null) {
          final startTime = _parseTime(schedule.start);
          final endTime = _parseTime(schedule.end);

          // Add buffer time at the start and end
          final adjustedStartTime =
              startTime.add(Duration(minutes: bufferMinutes));
          final adjustedEndTime =
              endTime.subtract(Duration(minutes: bufferMinutes));

          if (!adjustedStartTime.isAfter(adjustedEndTime)) {
            slots.add({
              'electrician_id': electricianId,
              'date': currentDate.toIso8601String().split('T')[0],
              'start_time': schedule.start,
              'end_time': schedule.end,
              'status': 'AVAILABLE',
            });
          }
        }

        currentDate = currentDate.add(const Duration(days: 1));
      }

      if (slots.isNotEmpty) {
        await _client.from('electrician_availability').insert(slots);
        await loadAvailabilitySlots(electricianId, startDate, endDate);
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error creating recurring slots', e, stackTrace);
      _error = 'Failed to create recurring slots';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an availability slot
  Future<void> updateAvailabilitySlot(
      String slotId, Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('electrician_availability')
          .update(updates)
          .eq('id', slotId)
          .select()
          .single();

      final updatedSlot = AvailabilitySlot.fromJson(response);
      final date = updatedSlot.date;

      final index =
          _availabilitySlots[date]?.indexWhere((slot) => slot.id == slotId) ??
              -1;
      if (index != -1) {
        _availabilitySlots[date]![index] = updatedSlot;
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error updating availability slot', e, stackTrace);
      _error = 'Failed to update availability slot';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete an availability slot
  Future<void> deleteAvailabilitySlot(String slotId, String date) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client.from('electrician_availability').delete().eq('id', slotId);

      _availabilitySlots[date]?.removeWhere((slot) => slot.id == slotId);
      if (_availabilitySlots[date]?.isEmpty ?? false) {
        _availabilitySlots.remove(date);
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error deleting availability slot', e, stackTrace);
      _error = 'Failed to delete availability slot';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if a slot conflicts with existing slots
  Future<bool> _hasConflict(AvailabilitySlot newSlot) async {
    final existingSlots = await _client
        .from('electrician_availability')
        .select()
        .eq('electrician_id', newSlot.electricianId)
        .eq('date', newSlot.date);

    for (final slot in existingSlots) {
      final existing = AvailabilitySlot.fromJson(slot);
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

  // Helper method to get day name
  String _getDayName(int weekday) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    return days[weekday - 1];
  }

  // Clear all data (useful when logging out)
  void clear() {
    _availabilitySlots = {};
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}

class AvailabilitySlot {
  final String id;
  final String electricianId;
  final String date;
  final String startTime;
  final String endTime;
  final String status;

  AvailabilitySlot({
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
