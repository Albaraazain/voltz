import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../core/services/logger_service.dart';
import '../models/electrician_model.dart';
import '../models/homeowner_model.dart';
import '../models/profile_model.dart';
import '../models/job_model.dart';
import 'auth_provider.dart';

class DatabaseProvider with ChangeNotifier {
  final SupabaseClient _client = SupabaseConfig.client;
  final AuthProvider _authProvider;
  List<Electrician> _electricians = [];
  Homeowner? _currentHomeowner;
  Profile? _currentProfile;
  bool _isLoading = false;

  DatabaseProvider(this._authProvider) {
    _initialize();
  }

  // Expose client for debugging
  SupabaseClient get client => _client;

  List<Electrician> get electricians => _electricians;
  Homeowner? get currentHomeowner => _currentHomeowner;
  Profile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    if (_authProvider.isAuthenticated) {
      await loadCurrentProfile();
      await loadElectricians();
    }
  }

  Future<void> loadCurrentProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = _authProvider.userId;
      if (userId == null) throw Exception('User not authenticated');

      // Load profile
      final profileResponse =
          await _client.from('profiles').select().eq('id', userId).single();
      _currentProfile = Profile.fromMap(profileResponse);

      // Load role-specific data
      switch (_currentProfile!.userType.toLowerCase()) {
        case 'homeowner':
          final homeownerResponse = await _client
              .from('homeowners')
              .select()
              .eq('profile_id', userId)
              .single();
          _currentHomeowner = Homeowner.fromMap(
            homeownerResponse,
            profile: _currentProfile,
          );
          break;
        case 'electrician':
          // Handle electrician profile if needed
          break;
        default:
          throw Exception('Invalid user type: ${_currentProfile!.userType}');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      LoggerService.error('Failed to load current profile', e, stackTrace);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadElectricians() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Join electricians with their profiles
      final response = await _client.from('electricians').select('''
            *,
            profile:profiles (*)
          ''');

      _electricians = response.map((data) {
        final profile = Profile.fromMap(data['profile']);
        return Electrician.fromMap(data, profile: profile);
      }).toList();

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
      await _client.from('homeowners').delete().neq('id', '0');
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

      // Sample profiles data
      final profiles = [
        {
          'id': '1',
          'email': 'john@example.com',
          'user_type': 'electrician',
          'name': 'John Doe',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'email': 'jane@example.com',
          'user_type': 'electrician',
          'name': 'Jane Smith',
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      // Insert sample profiles
      for (final profile in profiles) {
        await _client.from('profiles').upsert(profile);
      }

      // Sample electricians data
      final electricians = [
        {
          'id': '1',
          'profile_id': '1',
          'rating': 4.5,
          'jobs_completed': 25,
          'hourly_rate': 75.0,
          'is_available': true,
          'specialties': ['Residential', 'Commercial'],
          'license_number': 'EL123456',
          'years_of_experience': 5,
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'profile_id': '2',
          'rating': 4.8,
          'jobs_completed': 42,
          'hourly_rate': 85.0,
          'is_available': true,
          'specialties': ['Emergency', 'Installation'],
          'license_number': 'EL789012',
          'years_of_experience': 8,
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
          'date': DateTime.now().toIso8601String(),
          'price': 150.0,
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'homeowner_id': _authProvider.userId,
          'electrician_id': '2',
          'title': 'Install Outdoor Lighting',
          'description': 'Need to install outdoor security lights',
          'status': 'completed',
          'date': DateTime.now().toIso8601String(),
          'price': 300.0,
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
