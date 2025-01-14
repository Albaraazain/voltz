import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/logger_service.dart';
import '../models/availability_slot_model.dart';

class AvailabilityProvider extends ChangeNotifier {
  final SupabaseClient _client;
  bool _isLoading = false;
  Map<String, List<AvailabilitySlot>> _availabilitySlots = {};
  String? _error;

  AvailabilityProvider(this._client);

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, List<AvailabilitySlot>> get availabilitySlots =>
      _availabilitySlots;

  Future<void> loadAvailabilitySlots(
    String electricianId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('availability_slots')
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

  List<AvailabilitySlot> getAvailableSlots(
      DateTime date, String electricianId) {
    final dateStr = date.toIso8601String().split('T')[0];
    return _availabilitySlots[dateStr]
            ?.where((slot) =>
                slot.electricianId == electricianId &&
                slot.status == AvailabilitySlot.STATUS_AVAILABLE)
            .toList() ??
        [];
  }

  void clear() {
    _availabilitySlots = {};
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createAvailabilitySlot(AvailabilitySlot slot) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('availability_slots')
          .insert(slot.toJson())
          .select()
          .single();
      final date = response['date'] as String;

      if (!_availabilitySlots.containsKey(date)) {
        _availabilitySlots[date] = [];
      }
      _availabilitySlots[date]!.add(AvailabilitySlot.fromJson(response));
    } catch (e, stackTrace) {
      LoggerService.error('Error creating availability slot', e, stackTrace);
      _error = 'Failed to create availability slot';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAvailabilitySlot(String slotId, String date) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client.from('availability_slots').delete().eq('id', slotId);

      if (_availabilitySlots.containsKey(date)) {
        _availabilitySlots[date]!.removeWhere((slot) => slot.id == slotId);
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
}
