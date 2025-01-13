import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../core/services/logger_service.dart';
import '../models/job_model.dart';
import '../models/service_model.dart';
import '../models/working_hours_model.dart';
import '../models/electrician_model.dart';
import 'database_provider.dart';

class ElectricianProvider extends ChangeNotifier {
  final DatabaseProvider _databaseProvider;
  final SupabaseClient _client = SupabaseConfig.client;

  bool _isAvailable = true;
  String _currentStatus = 'Available';
  List<Job> _activeJobs = [];
  List<Service> _services = [];
  WorkingHours _workingHours = const WorkingHours();
  bool _isLoading = false;

  ElectricianProvider(this._databaseProvider) {
    _initialize();
  }

  bool get isAvailable => _isAvailable;
  String get currentStatus => _currentStatus;
  List<Job> get activeJobs => _activeJobs;
  List<Service> get services => _services;
  WorkingHours get workingHours => _workingHours;
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

      final electricianId = _getCurrentElectricianId();
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

      final electricianId = _getCurrentElectricianId();
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

      final electricianId = _getCurrentElectricianId();
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

      final electricianId = _getCurrentElectricianId();
      LoggerService.info(
          'Loading working hours for electrician: $electricianId');

      final response = await _client
          .from('electricians')
          .select('working_hours')
          .eq('id', electricianId)
          .single();

      LoggerService.debug(
          'Working hours response: ${response['working_hours']}');

      if (response['working_hours'] != null) {
        _workingHours = WorkingHours.fromJson(response['working_hours']);
        LoggerService.info('Working hours loaded successfully');
      } else {
        _workingHours = const WorkingHours();
        LoggerService.info('No working hours found, using defaults');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      LoggerService.error('Failed to load working hours', e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateAvailability(bool available) async {
    try {
      final electricianId = _getCurrentElectricianId();
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
      final electricianId = _getCurrentElectricianId();
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
      final electricianId = _getCurrentElectricianId();

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
      final electricianId = _getCurrentElectricianId();

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

  Future<void> updateWorkingHours(WorkingHours hours) async {
    try {
      final electricianId = _getCurrentElectricianId();
      await _client.from('working_hours').upsert({
        ...hours.toJson(),
        'electrician_id': electricianId,
      });

      _workingHours = hours;
      notifyListeners();
    } catch (e) {
      LoggerService.error('Failed to update working hours', e);
      rethrow;
    }
  }

  String _getCurrentElectricianId() {
    final electrician = _databaseProvider.electricians.firstWhere(
        (e) => e.profile.id == _databaseProvider.currentProfile?.id);
    return electrician.id;
  }
}
