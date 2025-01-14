import 'package:flutter/foundation.dart';
import 'package:supabase/supabase.dart';
import '../models/direct_request_model.dart';

class DirectRequestProvider extends ChangeNotifier {
  final SupabaseClient _supabase;
  bool _loading = false;
  String? _error;
  List<DirectRequest> _directRequests = [];

  DirectRequestProvider(this._supabase);

  List<DirectRequest> get pendingRequests => _directRequests
      .where((request) => request.status == DirectRequest.STATUS_PENDING)
      .toList();

  List<DirectRequest> get acceptedRequests => _directRequests
      .where((request) => request.status == DirectRequest.STATUS_ACCEPTED)
      .toList();

  List<DirectRequest> get declinedRequests => _directRequests
      .where((request) => request.status == DirectRequest.STATUS_DECLINED)
      .toList();

  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> loadHomeownerRequests(String homeownerId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('direct_requests')
          .select()
          .eq('homeowner_id', homeownerId);

      _directRequests = response
          .map<DirectRequest>((json) => DirectRequest.fromJson(json))
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

  Future<DirectRequest> createDirectRequest({
    required String homeownerId,
    required String electricianId,
    required String description,
    required DateTime preferredDate,
    required String preferredTime,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('direct_requests')
          .insert({
            'homeowner_id': homeownerId,
            'electrician_id': electricianId,
            'description': description,
            'preferred_date': preferredDate.toIso8601String().split('T')[0],
            'preferred_time': preferredTime,
            'status': DirectRequest.STATUS_PENDING,
          })
          .select()
          .single();

      final request = DirectRequest.fromJson(response);
      _directRequests.add(request);

      _loading = false;
      notifyListeners();

      return request;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> loadDirectRequests({
    required String electricianId,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('direct_requests')
          .select()
          .eq('electrician_id', electricianId);

      _directRequests = response
          .map<DirectRequest>((json) => DirectRequest.fromJson(json))
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

  Future<void> respondToDirectRequest({
    required String requestId,
    required String status,
    String? reason,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final data = {'status': status};
      if (reason != null) {
        data['decline_reason'] = reason;
      }

      final response = await _supabase
          .from('direct_requests')
          .update(data)
          .eq('id', requestId)
          .select()
          .single();

      if (status == DirectRequest.STATUS_ACCEPTED) {
        // Create job when request is accepted
        final request = DirectRequest.fromJson(response);
        await _supabase.from('jobs').insert({
          'homeowner_id': request.homeownerId,
          'electrician_id': request.electricianId,
          'title': 'Electrical Service',
          'description': request.description,
          'status': 'ACCEPTED',
          'date': DateTime.parse(
                  '${request.preferredDate}T${request.preferredTime}')
              .toIso8601String(),
          'price': 0.00, // Price will be set by electrician
        });
      }

      final index = _directRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _directRequests[index] = DirectRequest.fromJson(response);
      }

      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> proposeAlternativeTime({
    required String requestId,
    required DateTime alternativeDate,
    required String alternativeTime,
    String? message,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('direct_requests')
          .update({
            'alternative_date': alternativeDate.toIso8601String().split('T')[0],
            'alternative_time': alternativeTime,
            'alternative_message': message,
          })
          .eq('id', requestId)
          .select()
          .single();

      final index = _directRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _directRequests[index] = DirectRequest.fromJson(response);
      }

      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> loadElectricianRequests(String electricianId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('direct_requests')
          .select()
          .eq('electrician_id', electricianId);

      _directRequests = response
          .map<DirectRequest>((json) => DirectRequest.fromJson(json))
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

  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
    String? declineReason,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final data = {'status': status};
      if (declineReason != null) {
        data['decline_reason'] = declineReason;
      }

      final response = await _supabase
          .from('direct_requests')
          .update(data)
          .eq('id', requestId)
          .select()
          .single();

      final index = _directRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _directRequests[index] = DirectRequest.fromJson(response);
      }

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
