import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import '../services/logger_service.dart';

class SupabaseService {
  final SupabaseClient _client = SupabaseConfig.client;
  final _uuid = const Uuid();

  // Authentication Methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required bool isElectrician,
  }) async {
    try {
      LoggerService.info('Creating new user account: $email');

      // Create auth user
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Failed to create user account');
      }

      // Create user profile
      final userProfile = {
        'id': _uuid.v4(),
        'auth_id': response.user!.id,
        'name': name,
        'email': email,
        'password_hash':
            '', // We don't store password hash as Supabase handles auth
        'created_at': DateTime.now().toIso8601String(),
      };

      // Insert into appropriate table
      if (isElectrician) {
        await _client.from('electricians').insert({
          ...userProfile,
          'rating': 0.0,
          'jobs_completed': 0,
          'hourly_rate': 0.0,
          'is_available': true,
        });
      } else {
        await _client.from('homeowners').insert(userProfile);
      }

      LoggerService.info('User account created successfully');
      return response;
    } catch (e, stackTrace) {
      LoggerService.error('Failed to create user account', e, stackTrace);
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      LoggerService.info('Signing in user: $email');
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Failed to sign in');
      }

      LoggerService.info('User signed in successfully');
      return response;
    } catch (e, stackTrace) {
      LoggerService.error('Failed to sign in user', e, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      LoggerService.info('Signing out user');
      await _client.auth.signOut();
      LoggerService.info('User signed out successfully');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to sign out user', e, stackTrace);
      rethrow;
    }
  }

  // Profile Methods
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      LoggerService.info('Fetching user profile');

      // Try electrician first
      final electrician = await _client
          .from('electricians')
          .select()
          .eq('auth_id', userId)
          .single();

      return {'type': 'electrician', 'profile': electrician};

      // Try homeowner
      final homeowner = await _client
          .from('homeowners')
          .select()
          .eq('auth_id', userId)
          .single();

      return {'type': 'homeowner', 'profile': homeowner};

      return null;
    } catch (e, stackTrace) {
      LoggerService.error('Failed to fetch user profile', e, stackTrace);
      rethrow;
    }
  }

  // Database Operations
  Future<List<Map<String, dynamic>>> getElectricians() async {
    try {
      LoggerService.info('Fetching electricians');
      final response = await _client.from('electricians').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to fetch electricians', e, stackTrace);
      rethrow;
    }
  }

  Future<void> insertElectrician(Map<String, dynamic> electrician) async {
    try {
      LoggerService.info('Inserting electrician: ${electrician['name']}');
      await _client.from('electricians').insert(electrician);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to insert electrician', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getJobs(
      {String? homeownerId, String? electricianId}) async {
    try {
      LoggerService.info('Fetching jobs');
      var query = _client.from('jobs').select();

      if (homeownerId != null) {
        query = query.eq('homeowner_id', homeownerId);
      }
      if (electricianId != null) {
        query = query.eq('electrician_id', electricianId);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to fetch jobs', e, stackTrace);
      rethrow;
    }
  }

  Future<void> insertJob(Map<String, dynamic> job) async {
    try {
      LoggerService.info('Inserting job: ${job['title']}');
      await _client.from('jobs').insert(job);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to insert job', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      LoggerService.info('Updating job status: $jobId to $status');
      await _client.from('jobs').update({'status': status}).eq('id', jobId);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update job status', e, stackTrace);
      rethrow;
    }
  }

  // Auth State
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
}
