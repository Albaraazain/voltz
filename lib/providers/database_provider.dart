import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../core/services/logger_service.dart';
import '../models/electrician_model.dart';
import '../models/homeowner_model.dart';
import '../models/profile_model.dart';
import '../models/job_model.dart';
import '../models/review_model.dart';
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
    _authProvider.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    if (_authProvider.isAuthenticated) {
      loadCurrentProfile();
    } else {
      _currentHomeowner = null;
      _currentProfile = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
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
      LoggerService.info('Loading profile for user: $userId');
      if (userId == null) throw Exception('User not authenticated');

      // Load profile
      final profileResponse =
          await _client.from('profiles').select().eq('id', userId).single();
      LoggerService.debug('Loaded profile: $profileResponse');
      _currentProfile = Profile.fromMap(profileResponse);

      // Load role-specific data
      switch (_currentProfile!.userType.toLowerCase()) {
        case 'homeowner':
          LoggerService.info(
              'Loading homeowner data for profile: ${_currentProfile!.id}');
          final homeownerResponse = await _client
              .from('homeowners')
              .select()
              .eq('profile_id', userId)
              .single();
          LoggerService.debug('Loaded homeowner data: $homeownerResponse');
          _currentHomeowner = Homeowner.fromMap(
            homeownerResponse,
            profile: _currentProfile,
          );
          LoggerService.info('Successfully loaded homeowner profile');
          break;
        case 'electrician':
          LoggerService.info(
              'Loading electrician data for profile: ${_currentProfile!.id}');
          // Load electrician data
          await loadElectricians();
          if (_electricians.isEmpty) {
            throw Exception('Electrician profile not found');
          }
          LoggerService.info('Successfully loaded electrician profile');
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

      LoggerService.debug('Current profile type: ${_currentProfile?.userType}');

      // Build the base query with profile join
      final queryString = '''
        *,
        profile:profiles (
          id,
          email,
          user_type,
          name,
          created_at,
          last_login_at
        )
      ''';

      LoggerService.debug('Query string: $queryString');

      var query = _client.from('electricians').select(queryString);

      // Add filters based on user type
      if (_currentProfile?.userType.toLowerCase() == 'homeowner') {
        // For homeowners, only show verified electricians
        query = query.eq('is_verified', true);
        LoggerService.debug('Added homeowner filter: is_verified = true');
      } else if (_currentProfile?.userType.toLowerCase() == 'electrician' &&
          _currentProfile?.id != null) {
        // For electricians, only show their own profile
        query = query.eq('profile_id', _currentProfile!.id);
        LoggerService.debug(
            'Added electrician filter: profile_id = ${_currentProfile!.id}');
      } else if (_currentProfile?.userType.toLowerCase() == 'admin') {
        // Admins can see all electricians
        LoggerService.debug('No filter added for admin user');
      } else {
        // For unauthenticated users or unknown types, show no electricians
        _electricians = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await query;
      LoggerService.debug('Electricians response: $response');

      _electricians = response
          .map((data) {
            try {
              final profileData = data['profile'];
              Profile? profile;

              if (profileData == null) {
                LoggerService.warning(
                    'Missing profile data for electrician ${data['id']} with profile_id: ${data['profile_id']}');
                // Create a temporary profile for display purposes
                profile = Profile(
                  id: data['profile_id'],
                  email: 'Unknown',
                  userType: 'electrician',
                  name: 'Electrician #${data['id'].toString().substring(0, 8)}',
                  createdAt: DateTime.parse(data['created_at']),
                );
                LoggerService.warning(
                    'Created temporary profile for electrician: ${data['id']}');
              } else {
                LoggerService.debug(
                    'Successfully loaded profile data: $profileData');
                profile = Profile.fromMap(profileData);
              }

              return Electrician.fromMap(data, profile: profile);
            } catch (e, stackTrace) {
              LoggerService.error(
                  'Error parsing electrician data: $data', e, stackTrace);
              return null;
            }
          })
          .where((electrician) => electrician != null)
          .cast<Electrician>()
          .toList();

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

  // Job Management Methods
  Future<List<JobModel>> loadJobs({String? status}) async {
    try {
      LoggerService.info('Loading jobs');
      if (!_authProvider.isAuthenticated)
        throw Exception('User not authenticated');

      var query = _client.from('jobs').select('''
        *,
        electrician:electricians (
          id,
          profile:profiles (
            id,
            name,
            email
          )
        ),
        homeowner:homeowners (
          id,
          profile:profiles (
            id,
            name,
            email
          )
        )
      ''');

      // Filter based on user type and status
      if (_currentProfile?.userType.toLowerCase() == 'homeowner') {
        query = query.eq('homeowner_id', _currentProfile!.id);
      } else if (_currentProfile?.userType.toLowerCase() == 'electrician') {
        query = query.eq('electrician_id', _currentProfile!.id);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('created_at', ascending: false);
      return response.map((data) => JobModel.fromMap(data)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load jobs', e, stackTrace);
      rethrow;
    }
  }

  Future<JobModel> createJob(JobModel job) async {
    try {
      LoggerService.info('Creating job: ${job.title}');
      if (!_authProvider.isAuthenticated)
        throw Exception('User not authenticated');

      final response =
          await _client.from('jobs').insert(job.toMap()).select().single();

      return JobModel.fromMap(response);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to create job', e, stackTrace);
      rethrow;
    }
  }

  Future<JobModel> updateJob(JobModel job) async {
    try {
      LoggerService.info('Updating job: ${job.id}');
      if (!_authProvider.isAuthenticated)
        throw Exception('User not authenticated');

      final response = await _client
          .from('jobs')
          .update(job.toMap())
          .eq('id', job.id)
          .select()
          .single();

      return JobModel.fromMap(response);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update job', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      LoggerService.info('Deleting job: $jobId');
      if (!_authProvider.isAuthenticated)
        throw Exception('User not authenticated');

      await _client.from('jobs').delete().eq('id', jobId);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to delete job', e, stackTrace);
      rethrow;
    }
  }

  // Profile Management Methods
  Future<void> updateProfile(Profile profile) async {
    try {
      LoggerService.info('Updating profile: ${profile.id}');
      if (!_authProvider.isAuthenticated)
        throw Exception('User not authenticated');

      await _client
          .from('profiles')
          .update(profile.toMap())
          .eq('id', profile.id);

      await loadCurrentProfile();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update profile', e, stackTrace);
      rethrow;
    }
  }

  Future<String> uploadProfileImage(File file) async {
    try {
      LoggerService.info('Uploading profile image');
      if (!_authProvider.isAuthenticated)
        throw Exception('User not authenticated');

      final fileName =
          '${_currentProfile!.id}_${DateTime.now().millisecondsSinceEpoch}';
      await _client.storage.from('profile_images').upload(fileName, file);

      final imageUrl =
          _client.storage.from('profile_images').getPublicUrl(fileName);

      return imageUrl;
    } catch (e, stackTrace) {
      LoggerService.error('Failed to upload profile image', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateElectricianProfile(Electrician electrician) async {
    try {
      LoggerService.info('Updating electrician profile: ${electrician.id}');
      if (!_authProvider.isAuthenticated)
        throw Exception('User not authenticated');

      // Update profile first
      await updateProfile(electrician.profile);

      // Update electrician data with only the fields that exist in the database
      await _client.from('electricians').update({
        'hourly_rate': electrician.hourlyRate,
        'profile_image': electrician.profileImage,
        'is_available': electrician.isAvailable,
      }).eq('id', electrician.id);

      // Update local list if the electrician exists in it
      final index = _electricians.indexWhere((e) => e.id == electrician.id);
      if (index != -1) {
        _electricians[index] = electrician;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to update electrician profile', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateElectricianAvailability(
      String electricianId, bool isAvailable) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _client
          .from('electricians')
          .update({'is_available': isAvailable}).eq('id', electricianId);

      await loadElectricians();

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      LoggerService.error(
          'Failed to update electrician availability', e, stackTrace);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateElectricianServices(
      String electricianId, List<Service> services) async {
    try {
      LoggerService.info('Updating electrician services: $electricianId');
      if (!_authProvider.isAuthenticated)
        throw Exception('User not authenticated');

      await _client.from('electricians').update({
        'services': services.map((s) => s.toMap()).toList(),
      }).eq('id', electricianId);

      // Update local list if the electrician exists in it
      final index = _electricians.indexWhere((e) => e.id == electricianId);
      if (index != -1) {
        _electricians[index] =
            _electricians[index].copyWith(services: services);
        notifyListeners();
      }
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to update electrician services', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateElectricianWorkingHours(
      String electricianId, WorkingHours workingHours) async {
    try {
      LoggerService.info('Updating electrician working hours: $electricianId');
      if (!_authProvider.isAuthenticated)
        throw Exception('User not authenticated');

      await _client.from('electricians').update({
        'working_hours': workingHours.toMap(),
      }).eq('id', electricianId);

      // Update local list if the electrician exists in it
      final index = _electricians.indexWhere((e) => e.id == electricianId);
      if (index != -1) {
        _electricians[index] =
            _electricians[index].copyWith(workingHours: workingHours);
        notifyListeners();
      }
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to update electrician working hours', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateElectricianPaymentInfo(
      String electricianId, PaymentInfo paymentInfo) async {
    try {
      LoggerService.info('Updating electrician payment info: $electricianId');
      if (!_authProvider.isAuthenticated)
        throw Exception('User not authenticated');

      await _client.from('electricians').update({
        'payment_info': paymentInfo.toMap(),
      }).eq('id', electricianId);

      // Update local list if the electrician exists in it
      final index = _electricians.indexWhere((e) => e.id == electricianId);
      if (index != -1) {
        _electricians[index] =
            _electricians[index].copyWith(paymentInfo: paymentInfo);
        notifyListeners();
      }
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to update electrician payment info', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateElectricianNotificationPreferences(
    String electricianId,
    NotificationPreferences preferences,
  ) async {
    try {
      LoggerService.info(
          'Updating electrician notification preferences: $electricianId');
      if (!_authProvider.isAuthenticated)
        throw Exception('User not authenticated');

      await _client.from('electricians').update({
        'notification_preferences': preferences.toMap(),
      }).eq('id', electricianId);

      // Update local list if the electrician exists in it
      final index = _electricians.indexWhere((e) => e.id == electricianId);
      if (index != -1) {
        _electricians[index] = _electricians[index].copyWith(
          notificationPreferences: preferences,
        );
        notifyListeners();
      }
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to update electrician notification preferences',
          e,
          stackTrace);
      rethrow;
    }
  }

  // Real-time subscriptions
  void subscribeToJobs(void Function(JobModel) onJobUpdate) {
    _client
        .from('jobs')
        .stream(primaryKey: ['id']).listen((List<Map<String, dynamic>> data) {
      if (data.isNotEmpty) {
        final job = JobModel.fromMap(data.first);
        onJobUpdate(job);
      }
    });
  }

  // Electrician Management Methods
  Future<void> searchElectricians({
    String? searchQuery,
    List<String>? specialties,
    double? minRating,
    double? maxPrice,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final query = _client.from('electricians').select('''
            *,
            profile:profiles (
              id,
              email,
              user_type,
              name,
              created_at
            )
          ''').eq('is_verified', true);

      // Apply filters using filter() for complex queries
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query.filter('profile.name', 'ilike', '%$searchQuery%');
      }

      if (specialties != null && specialties.isNotEmpty) {
        query.filter('specialties', 'cs', specialties);
      }

      if (minRating != null) {
        query.filter('rating', 'gte', minRating);
      }

      if (maxPrice != null) {
        query.filter('hourly_rate', 'lte', maxPrice);
      }

      // Apply pagination and ordering
      final response = await query
          .range(offset, offset + limit - 1)
          .order('rating', ascending: false);

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

  // Cache Management
  final Map<String, dynamic> _cache = {};
  final Duration _cacheDuration = const Duration(minutes: 15);

  Future<T> _withCache<T>(String key, Future<T> Function() fetchData) async {
    final cacheEntry = _cache[key];
    if (cacheEntry != null) {
      final timestamp = cacheEntry['timestamp'] as DateTime;
      if (DateTime.now().difference(timestamp) < _cacheDuration) {
        return cacheEntry['data'] as T;
      }
    }

    final data = await fetchData();
    _cache[key] = {
      'data': data,
      'timestamp': DateTime.now(),
    };
    return data;
  }

  void clearCache() {
    _cache.clear();
  }

  // Enhanced Job Search
  Future<List<JobModel>> searchJobs({
    String? searchQuery,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final query = _client.from('jobs').select('''
        *,
        electrician:electricians (
          id,
          profile:profiles (id, name, email)
        ),
        homeowner:homeowners (
          id,
          profile:profiles (id, name, email)
        )
      ''');

      // Apply filters using filter() for complex queries
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query
            .filter('title', 'ilike', '%$searchQuery%')
            .filter('description', 'ilike', '%$searchQuery%');
      }

      if (status != null) {
        query.eq('status', status);
      }

      if (startDate != null) {
        query.filter('date', 'gte', startDate.toIso8601String());
      }

      if (endDate != null) {
        query.filter('date', 'lte', endDate.toIso8601String());
      }

      if (minPrice != null) {
        query.filter('price', 'gte', minPrice);
      }

      if (maxPrice != null) {
        query.filter('price', 'lte', maxPrice);
      }

      // Apply user-specific filters
      if (_currentProfile?.userType.toLowerCase() == 'homeowner') {
        query.eq('homeowner_id', _currentProfile!.id);
      } else if (_currentProfile?.userType.toLowerCase() == 'electrician') {
        query.eq('electrician_id', _currentProfile!.id);
      }

      // Apply pagination and ordering
      final response = await query
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: false);

      return response.map((data) => JobModel.fromMap(data)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to search jobs', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Review>> getElectricianReviews(String electricianId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            *,
            homeowner:homeowners (
              id,
              profile:profiles (
                id,
                email,
                user_type,
                name,
                created_at,
                last_login_at
              )
            )
          ''')
          .eq('electrician_id', electricianId)
          .order('created_at', ascending: false)
          .limit(10);

      return response.map((data) => Review.fromMap(data)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load electrician reviews', e, stackTrace);
      rethrow;
    }
  }

  // Add new methods for managing services
  Future<void> addElectricianService(Service service) async {
    try {
      final currentElectrician = electricians.firstWhere(
        (e) => e.profile.id == currentProfile?.id,
      );

      final updatedServices = [...currentElectrician.services, service];
      final updatedElectrician = currentElectrician.copyWith(
        services: updatedServices,
      );

      await updateElectricianProfile(updatedElectrician);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding service: $e');
      rethrow;
    }
  }

  Future<void> removeElectricianService(Service service) async {
    try {
      final currentElectrician = electricians.firstWhere(
        (e) => e.profile.id == currentProfile?.id,
      );

      final updatedServices = currentElectrician.services
          .where((s) => s.title != service.title)
          .toList();
      final updatedElectrician = currentElectrician.copyWith(
        services: updatedServices,
      );

      await updateElectricianProfile(updatedElectrician);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing service: $e');
      rethrow;
    }
  }
}
