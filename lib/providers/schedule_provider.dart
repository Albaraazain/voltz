import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/logger_service.dart';
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
  Future<wh.WorkingHours> loadWorkingHours(String electricianId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('electricians')
          .select('working_hours')
          .eq('id', electricianId)
          .single();

      final workingHours = wh.WorkingHours.fromJson(response['working_hours']);
      _loading = false;
      notifyListeners();
      return workingHours;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<wh.WorkingHours> updateWorkingHours(
      String electricianId, Map<String, dynamic> workingHours) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('electricians')
          .update({'working_hours': workingHours})
          .eq('id', electricianId)
          .select('working_hours')
          .single();

      final updatedWorkingHours =
          wh.WorkingHours.fromJson(response['working_hours']);
      _loading = false;
      notifyListeners();
      return updatedWorkingHours;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      rethrow;
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
      LoggerService.info('Creating schedule slot with parameters:\n'
          'Electrician ID: $electricianId\n'
          'Date: ${date.toIso8601String().split('T')[0]}\n'
          'Start Time: $startTime\n'
          'End Time: $endTime\n'
          'Status: $status');

      _loading = true;
      _error = null;
      notifyListeners();

      final data = {
        'electrician_id': electricianId,
        'date': date.toIso8601String().split('T')[0],
        'start_time': startTime,
        'end_time': endTime,
        'status': status,
        'job_id': jobId,
        'recurring_rule': recurringRule,
      };

      LoggerService.debug('Inserting data into schedule_slots table: $data');

      final response =
          await _supabase.from('schedule_slots').insert(data).select().single();

      LoggerService.debug('Database response: $response');

      final scheduleSlot = ScheduleSlot.fromJson(response);
      _scheduleSlots.add(scheduleSlot);

      LoggerService.info('Schedule slot created successfully:\n'
          'Slot ID: ${scheduleSlot.id}\n'
          'Date: ${scheduleSlot.date}\n'
          'Time: ${scheduleSlot.startTime} - ${scheduleSlot.endTime}');

      _loading = false;
      notifyListeners();
      return scheduleSlot;
    } catch (e, stackTrace) {
      final errorMsg = e.toString();
      LoggerService.error(
        'Failed to create schedule slot',
        e,
        stackTrace,
      );

      if (e is PostgrestException) {
        LoggerService.error(
          'PostgreSQL Error Details:\n'
          'Code: ${e.code}\n'
          'Message: ${e.message}\n'
          'Details: ${e.details}\n'
          'Hint: ${e.hint}',
        );
      }

      _error = errorMsg;
      _loading = false;
      notifyListeners();
      rethrow;
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
      rethrow;
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
      rethrow;
    }
  }

  Future<List<ScheduleSlot>> loadScheduleSlots({
    required String electricianId,
    required DateTime date,
  }) async {
    try {
      LoggerService.info('Loading schedule slots for:\n'
          'Electrician ID: $electricianId\n'
          'Date: ${date.toIso8601String().split('T')[0]}');

      _loading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('schedule_slots')
          .select()
          .eq('electrician_id', electricianId)
          .eq('date', date.toIso8601String().split('T')[0]);

      LoggerService.debug('Found ${response.length} slots');

      _scheduleSlots = response
          .map<ScheduleSlot>((json) => ScheduleSlot.fromJson(json))
          .toList();

      LoggerService.info('Successfully loaded schedule slots');

      _loading = false;
      notifyListeners();
      return _scheduleSlots;
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to load schedule slots',
        e,
        stackTrace,
      );

      _error = e.toString();
      _loading = false;
      notifyListeners();
      rethrow;
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
      rethrow;
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
      rethrow;
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

      final response = await _supabase
          .from('reschedule_requests')
          .select('*, job:jobs(id, homeowner_id, electrician_id)')
          .or('requested_by_id.eq.$userId,job->homeowner_id.eq.$userId,job->electrician_id.eq.$userId');

      _rescheduleRequests = response
          .map<RescheduleRequest>((json) => RescheduleRequest.fromJson(json))
          .toList();
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      rethrow;
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
      rethrow;
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
      rethrow;
    }
  }
}
