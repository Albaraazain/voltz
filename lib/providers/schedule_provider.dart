import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/working_hours_model.dart' as wh;
import '../models/schedule_slot_model.dart';
import '../models/reschedule_request_model.dart';

class ScheduleProvider extends ChangeNotifier {
  final SupabaseClient _supabase;
  String? _currentElectricianId;
  String? _currentHomeownerId;
  List<RescheduleRequest> _rescheduleRequests = [];
  List<ScheduleSlot> _scheduleSlots = [];
  bool _loading = false;
  String? _error;

  ScheduleProvider(this._supabase);

  bool get loading => _loading;
  String? get error => _error;
  List<ScheduleSlot> get scheduleSlots => _scheduleSlots;

  List<RescheduleRequest> get pendingRescheduleRequests => _rescheduleRequests
      .where((request) => request.status == RescheduleRequest.STATUS_PENDING)
      .toList();

  List<RescheduleRequest> get acceptedRescheduleRequests => _rescheduleRequests
      .where((request) => request.status == RescheduleRequest.STATUS_ACCEPTED)
      .toList();

  List<RescheduleRequest> get declinedRescheduleRequests => _rescheduleRequests
      .where((request) => request.status == RescheduleRequest.STATUS_DECLINED)
      .toList();

  Future<void> setCurrentHomeownerId(String homeownerId) async {
    _currentHomeownerId = homeownerId;
    notifyListeners();
  }

  // Working Hours Methods
  Future<wh.WorkingHours> setWorkingHours({
    required String electricianId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required bool isWorkingDay,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('working_hours')
          .upsert({
            'electrician_id': electricianId,
            'day_of_week': dayOfWeek,
            'start_time': startTime,
            'end_time': endTime,
            'is_working_day': isWorkingDay,
          })
          .select()
          .single();

      final workingHours = wh.WorkingHours.fromJson(response);
      _loading = false;
      notifyListeners();
      return workingHours;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      throw e;
    }
  }

  // Schedule Slot Methods
  Future<ScheduleSlot> createScheduleSlot({
    required String electricianId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String status,
    String? jobId,
    String? recurringRule,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('schedule_slots')
          .insert({
            'electrician_id': electricianId,
            'date': date.toIso8601String().split('T')[0],
            'start_time': startTime,
            'end_time': endTime,
            'status': status,
            'job_id': jobId,
            'recurring_rule': recurringRule,
          })
          .select()
          .single();

      final slot = ScheduleSlot.fromJson(response);
      _loading = false;
      notifyListeners();
      return slot;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<ScheduleSlot> bookSlot({
    required String slotId,
    required String homeownerId,
    required String description,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      // Get the slot details first
      final slotData = await _supabase
          .from('schedule_slots')
          .select()
          .eq('id', slotId)
          .single();

      final slot = ScheduleSlot.fromJson(slotData);

      // Delete the existing slot
      await _supabase.from('schedule_slots').delete().eq('id', slotId);

      // Call the create_booking function with the correct parameters
      final jobId = await _supabase.rpc('create_booking', params: {
        'p_electrician_id': slot.electricianId,
        'p_homeowner_id': homeownerId,
        'p_date': slot.date.toIso8601String().split('T')[0],
        'p_start_time': slot.startTime,
        'p_end_time': slot.endTime,
        'p_description': description,
      });

      // Get the updated slot
      final updatedSlotData = await _supabase
          .from('schedule_slots')
          .select()
          .eq('job_id', jobId)
          .single();

      final updatedSlot = ScheduleSlot.fromJson(updatedSlotData);
      _loading = false;
      notifyListeners();
      return updatedSlot;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<List<ScheduleSlot>> getAvailableSlots({
    required String electricianId,
    required DateTime date,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('schedule_slots')
          .select()
          .eq('electrician_id', electricianId)
          .eq('date', date.toIso8601String().split('T')[0])
          .eq('status', 'AVAILABLE');

      final slots =
          response.map((json) => ScheduleSlot.fromJson(json)).toList();
      _loading = false;
      notifyListeners();
      return slots;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<List<ScheduleSlot>> loadScheduleSlots({
    required String electricianId,
    required DateTime date,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('schedule_slots')
          .select()
          .eq('electrician_id', electricianId)
          .eq('date', date.toIso8601String().split('T')[0]);

      _scheduleSlots = response
          .map<ScheduleSlot>((json) => ScheduleSlot.fromJson(json))
          .toList();
      _loading = false;
      notifyListeners();
      return _scheduleSlots;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<List<wh.WorkingHours>> loadWorkingHours(String electricianId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('working_hours')
          .select()
          .eq('electrician_id', electricianId);

      final workingHours = response
          .map<wh.WorkingHours>((json) => wh.WorkingHours.fromJson(json))
          .toList();
      _loading = false;
      notifyListeners();
      return workingHours;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> createRescheduleRequest({
    required String jobId,
    required String requestedById,
    required String requestedByType,
    required DateTime originalDate,
    required String originalTime,
    required DateTime proposedDate,
    required String proposedTime,
    String? reason,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _supabase.from('reschedule_requests').insert({
        'job_id': jobId,
        'requested_by_id': requestedById,
        'requested_by_type': requestedByType,
        'original_date': originalDate.toIso8601String().split('T')[0],
        'original_time': originalTime,
        'proposed_date': proposedDate.toIso8601String().split('T')[0],
        'proposed_time': proposedTime,
        'reason': reason,
        'status': 'PENDING',
      });

      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> respondToRescheduleRequest({
    required String requestId,
    required String status,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _supabase
          .from('reschedule_requests')
          .update({'status': status}).eq('id', requestId);

      await loadRescheduleRequests(
        userId: _currentElectricianId!,
        userType: 'ELECTRICIAN',
      );

      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> loadRescheduleRequests({
    required String userId,
    required String userType,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase.from('reschedule_requests').select().or(
          'requested_by_id.eq.$userId,job.${userType.toLowerCase()}_id.eq.$userId');

      _rescheduleRequests = response
          .map<RescheduleRequest>((json) => RescheduleRequest.fromJson(json))
          .toList();
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> proposeNewTime({
    required String requestId,
    required DateTime newDate,
    required String newTime,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _supabase.from('reschedule_requests').update({
        'proposed_date': newDate.toIso8601String().split('T')[0],
        'proposed_time': newTime,
      }).eq('id', requestId);

      await loadRescheduleRequests(
        userId: _currentElectricianId!,
        userType: 'ELECTRICIAN',
      );

      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      throw e;
    }
  }

  bool get isLoading => _loading;

  Future<void> deleteScheduleSlot(String slotId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _supabase.from('schedule_slots').delete().eq('id', slotId);
      _scheduleSlots.removeWhere((slot) => slot.id == slotId);

      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      throw e;
    }
  }
}
