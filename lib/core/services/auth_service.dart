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

  Future<void> deleteAccount() async {
    try {
      LoggerService.info('Starting account deletion process');
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }
      LoggerService.info('Current user ID: ${user.id}');

      // First check if user is a homeowner
      LoggerService.info('Checking if user is a homeowner');
      final homeowner = await _client
          .from('homeowners')
          .select()
          .eq('profile_id', user.id)
          .maybeSingle();

      if (homeowner != null) {
        LoggerService.info('User is a homeowner with ID: ${homeowner['id']}');

        // Delete related records first
        LoggerService.info('Deleting homeowner reviews');
        await _client
            .from('reviews')
            .delete()
            .eq('homeowner_id', homeowner['id']);

        LoggerService.info('Deleting homeowner jobs');
        await _client.from('jobs').delete().eq('homeowner_id', homeowner['id']);

        LoggerService.info('Deleting homeowner payments');
        await _client.from('payments').delete().eq('payer_id', user.id);

        LoggerService.info('Deleting homeowner record');
        await _client.from('homeowners').delete().eq('profile_id', user.id);

        LoggerService.info(
            'Successfully deleted all homeowner related records');
      } else {
        // If not homeowner, check if electrician
        LoggerService.info('Checking if user is an electrician');
        final electrician = await _client
            .from('electricians')
            .select()
            .eq('profile_id', user.id)
            .maybeSingle();

        if (electrician != null) {
          LoggerService.info(
              'User is an electrician with ID: ${electrician['id']}');

          // Delete related records first
          LoggerService.info('Deleting electrician reviews');
          await _client
              .from('reviews')
              .delete()
              .eq('electrician_id', electrician['id']);

          LoggerService.info('Deleting electrician jobs');
          await _client
              .from('jobs')
              .delete()
              .eq('electrician_id', electrician['id']);

          LoggerService.info('Deleting electrician payments');
          await _client.from('payments').delete().eq('payee_id', user.id);

          LoggerService.info('Deleting electrician notifications');
          await _client
              .from('notifications')
              .delete()
              .eq('electrician_id', electrician['id']);

          LoggerService.info('Deleting electrician record');
          await _client.from('electricians').delete().eq('profile_id', user.id);

          LoggerService.info(
              'Successfully deleted all electrician related records');
        } else {
          LoggerService.info('User is neither a homeowner nor an electrician');
        }
      }

      // Create a new client with service role key for admin operations
      final adminClient = SupabaseClient(
        SupabaseConfig.supabaseUrl,
        SupabaseConfig.supabaseServiceRoleKey,
      );

      // Now safe to delete profile using admin client
      LoggerService.info('Deleting user profile');
      await adminClient.from('profiles').delete().eq('id', user.id);

      // Delete the auth user using admin client
      LoggerService.info('Deleting auth user');
      await adminClient.auth.admin.deleteUser(user.id);

      // Sign out the user
      LoggerService.info('Signing out user');
      await signOut();

      LoggerService.info('Account deletion completed successfully');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to delete user account', e, stackTrace);
      LoggerService.error('Error details: $e');
      LoggerService.error('Stack trace: $stackTrace');
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
