import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late SupabaseClient supabase;

  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://sjktidzfwyqfekvtpnwj.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqa3RpZHpmd3lxZmVrdnRwbndqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDQ4MjY3NjEsImV4cCI6MjAyMDQwMjc2MX0.Nh83ebqzf1iGHTaGywss6WIkkNlSiPHYId7aBHxuaWM',
    );
    supabase = Supabase.instance.client;
  });

  test('Notifications table structure is correct', () async {
    try {
      // Query table structure
      final structureResponse = await supabase
          .rpc('get_table_info', params: {'table_name': 'notifications'});

      expect(structureResponse, isNotNull);
      final columns = structureResponse as List;

      // Print column details for verification
      print('\nNotifications Table Structure:');
      for (final col in columns) {
        print('Column: ${col['column_name']}');
        print('  Type: ${col['data_type']}');
        print('  Nullable: ${col['is_nullable']}');
        print('  Default: ${col['column_default']}');
        print('');
      }

      // Verify required columns exist
      final columnNames = columns.map((col) => col['column_name']).toList();
      expect(
          columnNames,
          containsAll([
            'id',
            'profile_id',
            'title',
            'message',
            'type',
            'read',
            'related_id',
            'created_at',
            'updated_at'
          ]));

      // Verify column types
      final typeMap = Map.fromEntries(
        columns.map((col) => MapEntry(col['column_name'], col['data_type'])),
      );

      expect(typeMap['id'], equals('uuid'));
      expect(typeMap['profile_id'], equals('uuid'));
      expect(typeMap['title'], equals('text'));
      expect(typeMap['message'], equals('text'));
      expect(typeMap['type'], equals('text'));
      expect(typeMap['read'], equals('boolean'));
      expect(typeMap['related_id'], equals('uuid'));
      expect(typeMap['created_at'], equals('timestamp with time zone'));
      expect(typeMap['updated_at'], equals('timestamp with time zone'));
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  });

  tearDownAll(() async {
    await Supabase.instance.dispose();
  });
}
