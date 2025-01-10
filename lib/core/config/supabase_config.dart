import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://sjktidzfwyqfekvtpnwj.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqa3RpZHpmd3lxZmVrdnRwbndqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY0NDk5NjEsImV4cCI6MjA1MjAyNTk2MX0.RRhZaIJVeFZv23N22mIOrgbV_QryxpvClhsNR5JR--4';
  static const String supabaseServiceRoleKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqa3RpZHpmd3lxZmVrdnRwbndqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNjQ0OTk2MSwiZXhwIjoyMDUyMDI1OTYxfQ.a73hPqbvVT8HD8W6LLEPkCF4cWz-pkJYqI4LZnybih8';

  static SupabaseClient get client => Supabase.instance.client;
}
