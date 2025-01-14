import 'package:flutter_test/flutter_test.dart';
import 'package:supabase/supabase.dart';
import 'package:voltz/providers/schedule_provider.dart';
import 'package:voltz/models/working_hours_model.dart';
import 'package:uuid/uuid.dart';

void main() {
  late SupabaseClient supabase;
  late ScheduleProvider scheduleProvider;
  late String electricianId;
  late String homeownerId;
  late String electricianProfileId;
  late String homeownerProfileId;
  final uuid = Uuid();

  setUpAll(() async {
    // Initialize Supabase for testing with service role key to bypass RLS
    supabase = SupabaseClient(
      'http://127.0.0.1:54321',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU',
    );
    scheduleProvider = ScheduleProvider(supabase);

    // Create test data
    electricianProfileId = uuid.v4();
    homeownerProfileId = uuid.v4();

    // Create profiles
    await supabase.from('profiles').insert({
      'id': electricianProfileId,
      'email': 'test@example.com',
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
          'working_hours': {
            'monday': null,
            'tuesday': null,
            'wednesday': null,
            'thursday': null,
            'friday': null,
            'saturday': null,
            'sunday': null,
          },
        })
        .select()
        .single();
    electricianId = electricianData['id'];

    await supabase.from('profiles').insert({
      'id': homeownerProfileId,
      'email': 'homeowner@example.com',
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
  });

  tearDownAll(() async {
    // Clean up test data in reverse order of dependencies
    await supabase
        .from('schedule_slots')
        .delete()
        .eq('electrician_id', electricianId);
    await supabase.from('jobs').delete().eq('electrician_id', electricianId);
    await supabase.from('electricians').delete().eq('id', electricianId);
    await supabase.from('homeowners').delete().eq('id', homeownerId);
    await supabase.from('profiles').delete().eq('id', electricianProfileId);
    await supabase.from('profiles').delete().eq('id', homeownerProfileId);
  });

  group('Scheduling Flow Tests', () {
    test('Create and manage working hours', () async {
      // Update working hours
      final workingHours = await scheduleProvider.updateWorkingHours(
        electricianId,
        {
          'monday': {'start': '09:00', 'end': '17:00'},
          'tuesday': {'start': '09:00', 'end': '17:00'},
          'wednesday': {'start': '09:00', 'end': '17:00'},
          'thursday': {'start': '09:00', 'end': '17:00'},
          'friday': {'start': '09:00', 'end': '17:00'},
          'saturday': null,
          'sunday': null,
        },
      );

      expect(workingHours, isNotNull);
      expect(workingHours.monday?.start, '09:00');
      expect(workingHours.monday?.end, '17:00');
      expect(workingHours.saturday, isNull);
      expect(workingHours.sunday, isNull);

      // Create available slot
      final tomorrow = DateTime.now().add(Duration(days: 1));
      final slot = await scheduleProvider.createScheduleSlot(
        electricianId: electricianId,
        date: tomorrow,
        startTime: '10:00:00',
        endTime: '11:00:00',
        status: 'AVAILABLE',
      );

      expect(slot, isNotNull);
      expect(slot.status, 'AVAILABLE');
      expect(slot.startTime, '10:00:00');
      expect(slot.endTime, '11:00:00');

      // Get available slots
      final availableSlots = await scheduleProvider.getAvailableSlots(
        electricianId: electricianId,
        date: tomorrow,
      );

      expect(availableSlots, isNotEmpty);
      expect(availableSlots.first.id, slot.id);
      expect(availableSlots.first.startTime, '10:00:00');
      expect(availableSlots.first.endTime, '11:00:00');

      // Book the slot
      final booking = await scheduleProvider.bookSlot(
        slotId: slot.id,
        homeownerId: homeownerId,
        description: 'Test booking',
      );

      expect(booking, isNotNull);
      expect(booking.status, 'BOOKED');

      // Verify slot is no longer available
      final updatedAvailableSlots = await scheduleProvider.getAvailableSlots(
        electricianId: electricianId,
        date: tomorrow,
      );

      expect(updatedAvailableSlots, isEmpty);
    });
  });
}
