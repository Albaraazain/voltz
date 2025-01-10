import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'logger_service.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e, stackTrace) {
      LoggerService.error('Failed to sign in', e, stackTrace);
      rethrow;
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required bool isElectrician,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'is_electrician': isElectrician,
        },
      );

      if (response.user == null) {
        throw Exception('Failed to create user');
      }

      return response;
    } catch (e, stackTrace) {
      LoggerService.error('Failed to sign up', e, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to sign out', e, stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final electrician = await _client
          .from('electricians')
          .select()
          .eq('profile_id', userId)
          .single()
          .maybeSingle();

      if (electrician != null) {
        return {
          'type': 'electrician',
          'profile': electrician,
        };
      }

      final homeowner = await _client
          .from('homeowners')
          .select()
          .eq('profile_id', userId)
          .single()
          .maybeSingle();

      if (homeowner != null) {
        return {
          'type': 'homeowner',
          'profile': homeowner,
        };
      }

      return null;
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get user profile', e, stackTrace);
      rethrow;
    }
  }
}
