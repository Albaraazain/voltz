import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../core/services/logger_service.dart';
import '../models/job_model.dart';
import '../models/working_hours_model.dart' as wh;
import '../models/service_model.dart';
import 'database_provider.dart';

class ElectricianProvider extends ChangeNotifier {
  final DatabaseProvider _databaseProvider;
  final SupabaseClient _client = SupabaseConfig.client;

  bool _isAvailable = true;
  String _currentStatus = 'Available';
  List<Job> _activeJobs = [];
  List<Service> _services = [];
  List<wh.WorkingHours>? _workingHours;
  bool _isLoading = false;

  ElectricianProvider(this._databaseProvider) {
    _initialize();
  }

  bool get isAvailable => _isAvailable;
  String get currentStatus => _currentStatus;
  List<Job> get activeJobs => _activeJobs;
  List<Service> get services => _services;
  List<wh.WorkingHours>? get workingHours => _workingHours;
  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    await Future.wait([
      loadAvailability(),
      loadActiveJobs(),
      loadServices(),
      loadWorkingHours(),
    ]);
  }

  Future<void> loadAvailability() async {
    try {
      _isLoading = true;
      notifyListeners();

      final electricianId = getCurrentElectricianId();
      final response = await _client
          .from('electricians')
          .select('is_available')
          .eq('id', electricianId)
          .single();

      _isAvailable = response['is_available'] ?? false;
      _currentStatus = _isAvailable ? 'Available' : 'Unavailable';

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      LoggerService.error('Failed to load availability', e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadActiveJobs() async {
    try {
      _isLoading = true;
      notifyListeners();

      final electricianId = getCurrentElectricianId();
      final response = await _client
          .from('jobs')
          .select('''
            *,
            homeowner:homeowners (
              *,
              profile:profiles (*)
            )
          ''')
          .eq('electrician_id', electricianId)
          .or('status.in.(pending,accepted,in_progress)')
          .order('date', ascending: true);

      _activeJobs = response.map((job) => Job.fromJson(job)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      LoggerService.error('Failed to load active jobs', e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadServices() async {
    try {
      _isLoading = true;
      notifyListeners();

      final electricianId = getCurrentElectricianId();
      LoggerService.info('Loading services for electrician: $electricianId');

      final response = await _client
          .from('electricians')
          .select('services')
          .eq('id', electricianId)
          .single();

      LoggerService.debug('Services response: ${response['services']}');

      if (response['services'] != null) {
        _services = (response['services'] as List)
            .map((service) => Service.fromJson(service))
            .toList();
        LoggerService.info('Loaded ${_services.length} services');
      } else {
        _services = [];
        LoggerService.info('No services found');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      LoggerService.error('Failed to load services', e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadWorkingHours() async {
    try {
      _isLoading = true;
      notifyListeners();

      final electricianId = getCurrentElectricianId();
      LoggerService.info(
          'Loading working hours for electrician: $electricianId');

      final response = await _client.rpc(
        'get_working_hours',
        params: {'p_electrician_id': electricianId},
      );

      if (response == null) {
        LoggerService.error('No response from database query');
        throw Exception('Failed to load working hours');
      }

      _workingHours = (response as List)
          .map((day) => wh.WorkingHours.fromJson({
                'id': '${electricianId}_${day['day_of_week']}',
                'electrician_id': electricianId,
                'day_of_week': day['day_of_week'],
                'start_time': day['start_time'].toString().split('.')[0],
                'end_time': day['end_time'].toString().split('.')[0],
                'is_working_day': day['is_working_day'],
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              }))
          .toList();

      LoggerService.info(
          'Successfully loaded ${_workingHours?.length} working hours records');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      LoggerService.error('Failed to load working hours: ${e.toString()}');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateAvailability(bool available) async {
    try {
      final electricianId = getCurrentElectricianId();
      await _client
          .from('electricians')
          .update({'is_available': available}).eq('id', electricianId);

      _isAvailable = available;
      _currentStatus = available ? 'Available' : 'Unavailable';
      notifyListeners();
    } catch (e) {
      LoggerService.error('Failed to update availability', e);
      rethrow;
    }
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      await _client.from('jobs').update({'status': status}).eq('id', jobId);

      await loadActiveJobs();
    } catch (e) {
      LoggerService.error('Failed to update job status', e);
      rethrow;
    }
  }

  Future<void> addService(Service service) async {
    try {
      final electricianId = getCurrentElectricianId();
      LoggerService.info('Adding service for electrician: $electricianId');
      LoggerService.debug('Service details: ${service.toJson()}');

      // Generate a unique ID for the service
      final newService = service.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      // Get current services and add the new one
      final updatedServices = [..._services, newService];
      LoggerService.debug(
          'Updated services: ${updatedServices.map((s) => s.toJson()).toList()}');

      // Update the services column
      await _client.from('electricians').update({
        'services': updatedServices.map((s) => s.toJson()).toList(),
      }).eq('id', electricianId);

      _services = updatedServices;
      LoggerService.info('Service added successfully');
      notifyListeners();

      // Refresh the database provider to update the UI
      await _databaseProvider.loadElectricians();
    } catch (e) {
      LoggerService.error('Failed to add service', e);
      rethrow;
    }
  }

  Future<void> updateService(Service service) async {
    try {
      final electricianId = getCurrentElectricianId();

      // Update the service in the list
      final updatedServices = _services.map((s) {
        if (s.id == service.id) {
          return service;
        }
        return s;
      }).toList();

      // Update the services column
      await _client.from('electricians').update({
        'services': updatedServices.map((s) => s.toJson()).toList(),
      }).eq('id', electricianId);

      _services = updatedServices;
      notifyListeners();
    } catch (e) {
      LoggerService.error('Failed to update service', e);
      rethrow;
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      final electricianId = getCurrentElectricianId();

      // Remove the service from the list
      final updatedServices =
          _services.where((s) => s.id != serviceId).toList();

      // Update the services column
      await _client.from('electricians').update({
        'services': updatedServices.map((s) => s.toJson()).toList(),
      }).eq('id', electricianId);

      _services = updatedServices;
      notifyListeners();
    } catch (e) {
      LoggerService.error('Failed to delete service', e);
      rethrow;
    }
  }

  Future<void> updateWorkingHours(List<wh.WorkingHours> workingHours) async {
    try {
      _isLoading = true;
      notifyListeners();

      final electricianId = getCurrentElectricianId();
      LoggerService.info(
          'Updating working hours for electrician: $electricianId');

      // Update each day's working hours
      for (final day in workingHours) {
        await _client.from('working_hours').upsert({
          'electrician_id': electricianId,
          'day_of_week': day.dayOfWeek,
          'start_time': day.startTime,
          'end_time': day.endTime,
          'is_working_day': day.isWorkingDay,
        }, onConflict: 'electrician_id, day_of_week');
      }

      // Reload working hours to get the updated data
      await loadWorkingHours();

      LoggerService.info('Successfully updated working hours');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      LoggerService.error('Failed to update working hours: ${e.toString()}');
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> isWorkingTime(DateTime dateTime) async {
    try {
      final electricianId = getCurrentElectricianId();
      LoggerService.info(
          'Checking working time for electrician: $electricianId');

      final response = await _client.rpc('is_working_time', params: {
        'p_electrician_id': electricianId,
        'p_date': dateTime.toIso8601String().split('T')[0],
        'p_time':
            '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'
      });

      return response as bool;
    } catch (e) {
      LoggerService.error('Error checking working time: ${e.toString()}');
      rethrow;
    }
  }

  String getCurrentElectricianId() {
    if (_databaseProvider.currentProfile == null ||
        _databaseProvider.currentProfile!.userType.toLowerCase() !=
            'electrician') {
      throw Exception('No electrician is currently logged in');
    }

    final electrician = _databaseProvider.electricians.firstWhere(
      (e) => e.profile.id == _databaseProvider.currentProfile!.id,
      orElse: () => throw Exception('Electrician profile not found'),
    );

    return electrician.id;
  }
}
