import 'package:flutter_test/flutter_test.dart';
import 'package:supabase/supabase.dart';
import 'package:voltz/providers/direct_request_provider.dart';
import 'package:voltz/models/direct_request_model.dart';
import 'package:uuid/uuid.dart';

void main() {
  late SupabaseClient supabase;
  late DirectRequestProvider directRequestProvider;
  String? electricianId;
  String? homeownerId;
  String? electricianProfileId;
  String? homeownerProfileId;
  final uuid = Uuid();

  Future<void> cleanup() async {
    try {
      // Clean up test data in reverse order of dependencies
      if (electricianId != null) {
        await supabase
            .from('direct_requests')
            .delete()
            .filter('electrician_id', 'eq', electricianId);
        await supabase
            .from('jobs')
            .delete()
            .filter('electrician_id', 'eq', electricianId);
        await supabase
            .from('electricians')
            .delete()
            .filter('id', 'eq', electricianId);
      }
      if (homeownerId != null) {
        await supabase
            .from('homeowners')
            .delete()
            .filter('id', 'eq', homeownerId);
      }
      if (electricianProfileId != null) {
        await supabase
            .from('profiles')
            .delete()
            .filter('id', 'eq', electricianProfileId);
      }
      if (homeownerProfileId != null) {
        await supabase
            .from('profiles')
            .delete()
            .filter('id', 'eq', homeownerProfileId);
      }
    } catch (e) {
      print('Error during cleanup: $e');
    }
  }

  setUpAll(() async {
    // Initialize Supabase for testing with service role key to bypass RLS
    supabase = SupabaseClient(
      'http://127.0.0.1:54321',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU',
    );
    directRequestProvider = DirectRequestProvider(supabase);

    try {
      // Create test data
      electricianProfileId = uuid.v4();
      homeownerProfileId = uuid.v4();

      // Create profiles
      await supabase.from('profiles').insert({
        'id': electricianProfileId,
        'email': 'test.electrician.${uuid.v4()}@example.com',
        'name': 'Test User',
        'user_type': 'electrician',
      });

      final electricianData = await supabase
          .from('electricians')
          .insert({
            'profile_id': electricianProfileId,
            'hourly_rate': 100,
            'years_of_experience': 5,
            'license_number': 'TEST123',
          })
          .select()
          .single();
      electricianId = electricianData['id'];

      await supabase.from('profiles').insert({
        'id': homeownerProfileId,
        'email': 'test.homeowner.${uuid.v4()}@example.com',
        'name': 'Test Homeowner',
        'user_type': 'homeowner',
      });

      final homeownerData = await supabase
          .from('homeowners')
          .insert({
            'profile_id': homeownerProfileId,
            'phone': '1234567890',
            'address': '123 Test St',
          })
          .select()
          .single();
      homeownerId = homeownerData['id'];
    } catch (e) {
      // Clean up any data that was created before the error
      await cleanup();
      rethrow;
    }
  });

  tearDownAll(cleanup);

  group('Direct Request Flow Tests', () {
    test('Create and manage direct request', () async {
      // Create direct request
      final request = await directRequestProvider.createDirectRequest(
        homeownerId: homeownerId!,
        electricianId: electricianId!,
        description: 'Need urgent electrical work',
        preferredDate: DateTime.now().add(Duration(days: 2)),
        preferredTime: '14:00:00',
      );

      expect(request, isNotNull);
      expect(request.status, equals(DirectRequest.STATUS_PENDING));
      expect(request.homeownerId, equals(homeownerId));
      expect(request.electricianId, equals(electricianId));

      // Load direct requests for electrician
      await directRequestProvider.loadDirectRequests(
        electricianId: electricianId!,
      );

      expect(directRequestProvider.pendingRequests, isNotEmpty);
      final electricianRequest = directRequestProvider.pendingRequests.first;
      expect(electricianRequest.id, equals(request.id));

      // Accept direct request
      await directRequestProvider.respondToDirectRequest(
        requestId: request.id,
        status: DirectRequest.STATUS_ACCEPTED,
      );

      // Verify request status updated
      await directRequestProvider.loadDirectRequests(
        electricianId: electricianId!,
      );

      expect(directRequestProvider.acceptedRequests, isNotEmpty);
      expect(directRequestProvider.pendingRequests, isEmpty);
      final acceptedRequest = directRequestProvider.acceptedRequests.first;
      expect(acceptedRequest.id, equals(request.id));
      expect(acceptedRequest.status, equals(DirectRequest.STATUS_ACCEPTED));

      // Verify job was created
      final jobs = await supabase
          .from('jobs')
          .select()
          .filter('homeowner_id', 'eq', homeownerId)
          .filter('electrician_id', 'eq', electricianId);

      expect(jobs, isNotEmpty);
      final job = jobs.first;
      expect(job['status'], equals('ACCEPTED'));
      expect(job['description'], equals('Need urgent electrical work'));
      expect(job['title'], equals('Electrical Service'));
      expect(job['date'], isNotNull);
    });

    test('Decline direct request', () async {
      // Create direct request
      final request = await directRequestProvider.createDirectRequest(
        homeownerId: homeownerId!,
        electricianId: electricianId!,
        description: 'Another electrical job',
        preferredDate: DateTime.now().add(Duration(days: 3)),
        preferredTime: '15:00:00',
      );

      // Decline the request
      await directRequestProvider.respondToDirectRequest(
        requestId: request.id,
        status: DirectRequest.STATUS_DECLINED,
        reason: 'Schedule conflict',
      );

      // Verify request status updated
      await directRequestProvider.loadDirectRequests(
        electricianId: electricianId!,
      );

      expect(directRequestProvider.declinedRequests, isNotEmpty);
      final declinedRequest = directRequestProvider.declinedRequests.first;
      expect(declinedRequest.id, equals(request.id));
      expect(declinedRequest.status, equals(DirectRequest.STATUS_DECLINED));

      // Verify no job was created
      final jobs = await supabase
          .from('jobs')
          .select()
          .filter('homeowner_id', 'eq', homeownerId)
          .filter('electrician_id', 'eq', electricianId)
          .filter('description', 'eq', 'Another electrical job');

      expect(jobs, isEmpty);
    });

    test('Propose alternative time for direct request', () async {
      // Create direct request
      final request = await directRequestProvider.createDirectRequest(
        homeownerId: homeownerId!,
        electricianId: electricianId!,
        description: 'Electrical maintenance',
        preferredDate: DateTime.now().add(Duration(days: 4)),
        preferredTime: '16:00:00',
      );

      // Propose alternative time
      final alternativeDate = DateTime.now().add(Duration(days: 5));
      await directRequestProvider.proposeAlternativeTime(
        requestId: request.id,
        alternativeDate: alternativeDate,
        alternativeTime: '10:00:00',
        message: 'How about this time instead?',
      );

      // Verify request was updated
      await directRequestProvider.loadDirectRequests(
        electricianId: electricianId!,
      );

      final updatedRequest = directRequestProvider.pendingRequests.first;
      expect(updatedRequest.id, equals(request.id));
      expect(updatedRequest.alternativeDate,
          equals(alternativeDate.toIso8601String().split('T')[0]));
      expect(updatedRequest.alternativeTime, equals('10:00:00'));
      expect(updatedRequest.status, equals(DirectRequest.STATUS_PENDING));
    });
  });
}
