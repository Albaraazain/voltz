import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../core/services/logger_service.dart';
import '../models/electrician.dart';
import '../models/job.dart';
import 'auth_provider.dart';

class DatabaseProvider with ChangeNotifier {
  final SupabaseClient _client = SupabaseConfig.client;
  final AuthProvider _authProvider;
  List<Electrician> _electricians = [];
  bool _isLoading = false;

  DatabaseProvider(this._authProvider) {
    _initialize();
  }

  List<Electrician> get electricians => _electricians;
  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    await loadElectricians();
  }

  Future<void> loadElectricians() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _client.from('electricians').select();
      _electricians =
          response.map((data) => Electrician.fromMap(data)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      LoggerService.error('Failed to load electricians', e, stackTrace);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addElectrician(Electrician electrician) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to add an electrician');
      }

      await _client.from('electricians').upsert(electrician.toMap());
      await loadElectricians();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to add electrician', e, stackTrace);
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to clear data');
      }

      await _client.from('jobs').delete().neq('id', '0');
      await _client.from('electricians').delete().neq('id', '0');
      await loadElectricians();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to clear data', e, stackTrace);
      rethrow;
    }
  }

  Future<void> initializeData() async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to initialize data');
      }

      // Sample electricians data
      final electricians = [
        {
          'id': '1',
          'name': 'John Doe',
          'email': 'john@example.com',
          'rating': 4.5,
          'jobs_completed': 25,
          'hourly_rate': 75.0,
          'is_available': true,
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'name': 'Jane Smith',
          'email': 'jane@example.com',
          'rating': 4.8,
          'jobs_completed': 42,
          'hourly_rate': 85.0,
          'is_available': true,
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      // Insert sample electricians
      for (final electrician in electricians) {
        await _client.from('electricians').upsert(electrician);
      }

      // Sample jobs data
      final jobs = [
        {
          'id': '1',
          'homeowner_id': _authProvider.userId,
          'electrician_id': '1',
          'title': 'Fix Kitchen Lights',
          'description': 'Kitchen lights are flickering and need repair',
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'homeowner_id': _authProvider.userId,
          'electrician_id': '2',
          'title': 'Install Outdoor Lighting',
          'description': 'Need to install outdoor security lights',
          'status': 'completed',
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      // Insert sample jobs
      for (final job in jobs) {
        await _client.from('jobs').upsert(job);
      }

      await loadElectricians();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to initialize data', e, stackTrace);
      rethrow;
    }
  }
}
