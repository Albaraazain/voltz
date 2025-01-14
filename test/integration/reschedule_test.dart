import 'package:flutter_test/flutter_test.dart';
import 'package:supabase/supabase.dart';
import 'package:voltz/providers/schedule_provider.dart';
import 'package:voltz/models/reschedule_request_model.dart';
import 'package:uuid/uuid.dart';

void main() {
  late SupabaseClient supabase;
  late ScheduleProvider scheduleProvider;
  String? electricianId;
  String? homeownerId;
  String? electricianProfileId;
  String? homeownerProfileId;
  String? jobId;
  final uuid = Uuid();

  Future<void> cleanup() async {
    try {
      // Clean up test data in reverse order of dependencies
      if (jobId != null) {
        await supabase
            .from('reschedule_requests')
            .delete()
            .filter('job_id', 'eq', jobId);
        await supabase.from('jobs').delete().filter('id', 'eq', jobId);
      }
      if (electricianId != null) {
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
    scheduleProvider = ScheduleProvider(supabase);

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

      // Create a test job
      final jobData = await supabase
          .from('jobs')
          .insert({
            'homeowner_id': homeownerId,
            'electrician_id': electricianId,
            'title': 'Test Job',
            'description': 'Test job description',
            'status': 'ACCEPTED',
            'date': DateTime.now().add(Duration(days: 1)).toIso8601String(),
            'price': 100.00,
          })
          .select()
          .single();
      jobId = jobData['id'];
    } catch (e) {
      // Clean up any data that was created before the error
      await cleanup();
      rethrow;
    }
  });

  tearDownAll(cleanup);

  group('Reschedule Request Flow Tests', () {
    test('Create and manage reschedule request', () async {
      // Create reschedule request
      final originalDate = DateTime.now().add(Duration(days: 1));
      final proposedDate = DateTime.now().add(Duration(days: 2));

      await scheduleProvider.createRescheduleRequest(
        jobId: jobId!,
        requestedById: homeownerId!,
        requestedByType: 'HOMEOWNER',
        originalDate: originalDate,
        originalTime: '10:00:00',
        proposedDate: proposedDate,
        proposedTime: '14:00:00',
        reason: 'Schedule conflict',
      );

      // Load reschedule requests for homeowner
      await scheduleProvider.loadRescheduleRequests(
        userId: homeownerId!,
        userType: 'HOMEOWNER',
      );

      expect(scheduleProvider.pendingRescheduleRequests, isNotEmpty);
      final request = scheduleProvider.pendingRescheduleRequests.first;
      expect(request.status, equals(RescheduleRequest.STATUS_PENDING));
      expect(request.jobId, equals(jobId));
      expect(request.requestedById, equals(homeownerId));
      expect(request.reason, equals('Schedule conflict'));

      // Load reschedule requests for electrician
      await scheduleProvider.loadRescheduleRequests(
        userId: electricianId!,
        userType: 'ELECTRICIAN',
      );

      expect(scheduleProvider.pendingRescheduleRequests, isNotEmpty);
      final electricianRequest =
          scheduleProvider.pendingRescheduleRequests.first;
      expect(electricianRequest.id, equals(request.id));

      // Accept reschedule request
      await scheduleProvider.respondToRescheduleRequest(
        requestId: request.id,
        status: RescheduleRequest.STATUS_ACCEPTED,
      );

      // Verify request status updated
      await scheduleProvider.loadRescheduleRequests(
        userId: homeownerId!,
        userType: 'HOMEOWNER',
      );

      expect(scheduleProvider.acceptedRescheduleRequests, isNotEmpty);
      expect(scheduleProvider.pendingRescheduleRequests, isEmpty);
      final acceptedRequest = scheduleProvider.acceptedRescheduleRequests.first;
      expect(acceptedRequest.id, equals(request.id));
      expect(acceptedRequest.status, equals(RescheduleRequest.STATUS_ACCEPTED));
    });

    test('Propose new time for reschedule request', () async {
      // Create initial reschedule request
      final originalDate = DateTime.now().add(Duration(days: 1));
      final proposedDate = DateTime.now().add(Duration(days: 2));

      await scheduleProvider.createRescheduleRequest(
        jobId: jobId!,
        requestedById: homeownerId!,
        requestedByType: 'HOMEOWNER',
        originalDate: originalDate,
        originalTime: '10:00:00',
        proposedDate: proposedDate,
        proposedTime: '14:00:00',
        reason: 'Schedule conflict',
      );

      await scheduleProvider.loadRescheduleRequests(
        userId: homeownerId!,
        userType: 'HOMEOWNER',
      );

      final request = scheduleProvider.pendingRescheduleRequests.first;

      // Propose new time
      final newDate = DateTime.now().add(Duration(days: 3));
      await scheduleProvider.proposeNewTime(
        requestId: request.id,
        newDate: newDate,
        newTime: '15:00:00',
      );

      // Verify new time was proposed
      await scheduleProvider.loadRescheduleRequests(
        userId: homeownerId!,
        userType: 'HOMEOWNER',
      );

      final updatedRequest = scheduleProvider.pendingRescheduleRequests.first;
      expect(updatedRequest.id, equals(request.id));
      expect(updatedRequest.proposedDate,
          equals(newDate.toIso8601String().split('T')[0]));
      expect(updatedRequest.proposedTime, equals('15:00:00'));
    });
  });
}
