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
import '../models/service_model.dart';
import '../models/working_hours_model.dart';
import '../models/payment_info_model.dart';
import '../models/notification_preferences_model.dart';
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
      _currentProfile = Profile.fromJson(profileResponse);

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
          _currentHomeowner = Homeowner.fromJson(
            homeownerResponse,
            profile: _currentProfile!,
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
    } catch (e) {
      _isLoading = false;
      LoggerService.error(
        'Failed to load current profile',
      );
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
                profile = Profile.fromJson(profileData);
              }

              final electrician = Electrician.fromJson(data);
              return electrician.copyWith(profile: profile);
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

      await _client.from('electricians').upsert(electrician.toJson());
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
  Future<List<Job>> loadJobs({String? status}) async {
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
      return response.map((data) => Job.fromJson(data)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load jobs', e, stackTrace);
      rethrow;
    }
  }

  Future<Job> createJob(Job job) async {
    try {
      LoggerService.info('Creating job: ${job.title}');
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to create a job');
      }

      final response =
          await _client.from('jobs').insert(job.toJson()).select().single();

      return Job.fromJson(response);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to create job', e, stackTrace);
      rethrow;
    }
  }

  Future<Job> updateJob(Job job) async {
    try {
      LoggerService.info('Updating job: ${job.id}');
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to update a job');
      }

      final response = await _client
          .from('jobs')
          .update(job.toJson())
          .eq('id', job.id)
          .select()
          .single();

      return Job.fromJson(response);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update job', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to delete a job');
      }

      await _client.from('jobs').delete().eq('id', jobId);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to delete job', e, stackTrace);
      rethrow;
    }
  }

  // Profile Management Methods
  Future<void> updateProfile(Profile profile) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to update profile');
      }

      await _client
          .from('profiles')
          .update(profile.toJson())
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

  Future<void> updateElectricianServices(List<Service> services) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to update services');
      }

      final electrician = _electricians.firstWhere(
          (e) => e.profile.id == _currentProfile!.id,
          orElse: () => throw Exception('Electrician not found'));

      await _client
          .from('electricians')
          .update({'services': services.map((s) => s.toJson()).toList()}).eq(
              'id', electrician.id);

      await loadElectricians();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update services', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateElectricianWorkingHours(WorkingHours workingHours) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to update working hours');
      }

      final electrician = _electricians.firstWhere(
          (e) => e.profile.id == _currentProfile!.id,
          orElse: () => throw Exception('Electrician not found'));

      await _client.from('electricians').update(
          {'workingHours': workingHours.toJson()}).eq('id', electrician.id);

      await loadElectricians();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update working hours', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateElectricianPaymentInfo(PaymentInfo? paymentInfo) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to update payment info');
      }

      final electrician = _electricians.firstWhere(
          (e) => e.profile.id == _currentProfile!.id,
          orElse: () => throw Exception('Electrician not found'));

      await _client.from('electricians').update(
          {'paymentInfo': paymentInfo?.toJson()}).eq('id', electrician.id);

      await loadElectricians();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update payment info', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateElectricianNotificationPreferences(
      NotificationPreferences preferences) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception(
            'User must be authenticated to update notification preferences');
      }

      final electrician = _electricians.firstWhere(
          (e) => e.profile.id == _currentProfile!.id,
          orElse: () => throw Exception('Electrician not found'));

      await _client
          .from('electricians')
          .update({'notificationPreferences': preferences.toJson()}).eq(
              'id', electrician.id);

      await loadElectricians();
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to update notification preferences', e, stackTrace);
      rethrow;
    }
  }

  // Real-time subscriptions
  void subscribeToJobs(void Function(Job) onJobUpdate) {
    _client
        .from('jobs')
        .stream(primaryKey: ['id']).listen((List<Map<String, dynamic>> data) {
      if (data.isNotEmpty) {
        final job = Job.fromJson(data.first);
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
        final profile = Profile.fromJson(data['profile']);
        return Electrician.fromJson(data);
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
  Future<List<Job>> searchJobs({
    String? searchQuery,
    String? status,
    String? electricianId,
    String? homeownerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client.from('jobs').select();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query
            .or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      if (electricianId != null) {
        query = query.eq('electrician_id', electricianId);
      }

      if (homeownerId != null) {
        query = query.eq('homeowner_id', homeownerId);
      }

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String());
      }

      final response = await query.order('created_at', ascending: false);

      return response.map((data) => Job.fromJson(data)).toList();
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

      return response.map((data) => Review.fromJson(data)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load electrician reviews', e, stackTrace);
      rethrow;
    }
  }

  // Add new methods for managing services
  Future<void> addElectricianService(Service service) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to add service');
      }

      final electrician = _electricians.firstWhere(
          (e) => e.profile.id == _currentProfile!.id,
          orElse: () => throw Exception('Electrician not found'));

      final services = [...electrician.services, service];
      await updateElectricianServices(services);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to add service', e, stackTrace);
      rethrow;
    }
  }

  Future<void> removeElectricianService(Service service) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to remove service');
      }

      final electrician = _electricians.firstWhere(
          (e) => e.profile.id == _currentProfile!.id,
          orElse: () => throw Exception('Electrician not found'));

      final services =
          electrician.services.where((s) => s.title != service.title).toList();
      await updateElectricianServices(services);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to remove service', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Job>> getJobsForElectrician(String electricianId) async {
    try {
      final response = await _client
          .from('jobs')
          .select()
          .eq('electrician_id', electricianId);
      return response.map((job) => Job.fromJson(job)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get jobs for electrician', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Job>> getJobsForHomeowner(String homeownerId) async {
    try {
      final response =
          await _client.from('jobs').select().eq('homeowner_id', homeownerId);
      return response.map((job) => Job.fromJson(job)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get jobs for homeowner', e, stackTrace);
      rethrow;
    }
  }

  Future<Job?> getJob(String jobId) async {
    try {
      final response =
          await _client.from('jobs').select().eq('id', jobId).single();
      return Job.fromJson(response);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get job', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Review>> getReviewsForElectrician(String electricianId) async {
    try {
      final response = await _client
          .from('reviews')
          .select()
          .eq('electrician_id', electricianId);
      return response.map((review) => Review.fromJson(review)).toList();
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to get reviews for electrician', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updatePaymentInfo(PaymentInfo paymentInfo) async {
    if (!_authProvider.isAuthenticated) {
      throw Exception(
          'User must be authenticated to update payment information');
    }

    try {
      final currentElectrician = electricians.firstWhere(
        (e) => e.profile.id == currentProfile?.id,
      );

      final updatedElectrician = currentElectrician.copyWith(
        paymentInfo: paymentInfo,
      );

      await _client.from('electricians').upsert(updatedElectrician.toJson());
      notifyListeners();
    } catch (e) {
      LoggerService.error('Error updating payment info: $e');
      rethrow;
    }
  }

  Future<void> updateHomeownerNotificationPreferences({
    required bool jobUpdates,
    required bool messages,
    required bool payments,
    required bool promotions,
  }) async {
    try {
      if (_currentHomeowner == null) {
        throw Exception('No homeowner logged in');
      }

      await _client.from('homeowners').update({
        'notification_job_updates': jobUpdates,
        'notification_messages': messages,
        'notification_payments': payments,
        'notification_promotions': promotions,
      }).eq('id', _currentHomeowner!.id);

      // Update local state
      _currentHomeowner = Homeowner(
        id: _currentHomeowner!.id,
        profile: _currentHomeowner!.profile,
        phone: _currentHomeowner!.phone,
        address: _currentHomeowner!.address,
        preferredContactMethod: _currentHomeowner!.preferredContactMethod,
        emergencyContact: _currentHomeowner!.emergencyContact,
        createdAt: _currentHomeowner!.createdAt,
        notificationJobUpdates: jobUpdates,
        notificationMessages: messages,
        notificationPayments: payments,
        notificationPromotions: promotions,
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHomeownerContactPreference(String method) async {
    try {
      if (_currentHomeowner == null) {
        throw Exception('No homeowner logged in');
      }

      await _client.from('homeowners').update({
        'preferred_contact_method': method,
      }).eq('id', _currentHomeowner!.id);

      // Update local state
      _currentHomeowner = Homeowner(
        id: _currentHomeowner!.id,
        profile: _currentHomeowner!.profile,
        phone: _currentHomeowner!.phone,
        address: _currentHomeowner!.address,
        preferredContactMethod: method,
        emergencyContact: _currentHomeowner!.emergencyContact,
        createdAt: _currentHomeowner!.createdAt,
        notificationJobUpdates: _currentHomeowner!.notificationJobUpdates,
        notificationMessages: _currentHomeowner!.notificationMessages,
        notificationPayments: _currentHomeowner!.notificationPayments,
        notificationPromotions: _currentHomeowner!.notificationPromotions,
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHomeownerPersonalInfo({
    required String name,
    required String phone,
    required String emergencyContact,
  }) async {
    try {
      if (_currentHomeowner == null) {
        throw Exception('No homeowner logged in');
      }

      // Update profile name
      await _client.from('profiles').update({
        'name': name,
      }).eq('id', _currentProfile!.id);

      // Update homeowner phone and emergency contact
      await _client.from('homeowners').update({
        'phone': phone,
        'emergency_contact': emergencyContact,
      }).eq('id', _currentHomeowner!.id);

      // Update local profile state
      _currentProfile = Profile(
        id: _currentProfile!.id,
        email: _currentProfile!.email,
        userType: _currentProfile!.userType,
        name: name,
        createdAt: _currentProfile!.createdAt,
      );

      // Update local homeowner state
      _currentHomeowner = Homeowner(
        id: _currentHomeowner!.id,
        profile: _currentProfile!,
        phone: phone,
        address: _currentHomeowner!.address,
        preferredContactMethod: _currentHomeowner!.preferredContactMethod,
        emergencyContact: emergencyContact,
        createdAt: _currentHomeowner!.createdAt,
        notificationJobUpdates: _currentHomeowner!.notificationJobUpdates,
        notificationMessages: _currentHomeowner!.notificationMessages,
        notificationPayments: _currentHomeowner!.notificationPayments,
        notificationPromotions: _currentHomeowner!.notificationPromotions,
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHomeownerAddress(String address) async {
    try {
      if (_currentHomeowner == null) {
        throw Exception('No homeowner logged in');
      }

      await _client.from('homeowners').update({
        'address': address,
      }).eq('id', _currentHomeowner!.id);

      // Update local state
      _currentHomeowner = Homeowner(
        id: _currentHomeowner!.id,
        profile: _currentHomeowner!.profile,
        phone: _currentHomeowner!.phone,
        address: address,
        preferredContactMethod: _currentHomeowner!.preferredContactMethod,
        emergencyContact: _currentHomeowner!.emergencyContact,
        createdAt: _currentHomeowner!.createdAt,
        notificationJobUpdates: _currentHomeowner!.notificationJobUpdates,
        notificationMessages: _currentHomeowner!.notificationMessages,
        notificationPayments: _currentHomeowner!.notificationPayments,
        notificationPromotions: _currentHomeowner!.notificationPromotions,
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
